class Games::ZeroOnesController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    @options = []
    @options << "セパレートブル" if @game.separate_bull?
    @options << "マスターアウト" if @game.master_out?
    # 続きから
    @rounds = @game.game_rounds.order(:created_at)
    @round_number = @rounds.count + 1
    @current_score = @game.start_score - @rounds.where(bust: false).sum(:score)
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0
    darts = params[:results]
    bust = ActiveRecord::Type::Boolean.new.cast(params[:bust])
    clear = ActiveRecord::Type::Boolean.new.cast(params[:clear])
    created_darts = []

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    game_id = params[:game_id]
    game = Game.find(game_id)
    game_round = GameRound.create!(
      game_id: game_id,
      bust: bust
    )

    darts.each_with_index do |dart, index|
      now_dart = Dart.create!(
        game_round_id: game_round.id,
        segment: dart[:segment],
        multiplier: dart[:multiplier],
        number: index + 1,
        absolute_r: dart[:absolute_r],
        absolute_0: dart[:absolute_0],
        index_r: dart[:r],
        index_n: dart[:n],
        target: dart[:target],
        bounce_out: dart[:bounce_out]
      )
      created_darts << now_dart

      if calc.hit?(now_dart)
        hit += 1
      end

      if calc.s_bull?(now_dart)
        s_bull += 1
      end

      if calc.d_bull?(now_dart)
        d_bull += 1
      end
    end

    if game.separate_bull?
      score, range = calc.separate_score_and_range(created_darts)
    else
      score, range = calc.score_and_range(created_darts)
    end
    awards = calc.award(created_darts, score)
    analysis = calc.analysis_columns(created_darts)
    game_round.update!(
      {
        hit: hit,
        s_bull: s_bull,
        d_bull: d_bull,
        score: score,
        range: range
      }.merge(awards).merge(analysis)
    )

    if clear
      game = Game.find(game_id)
      judge_score = (game.start_score - 1) * 0.2
      rounds = game.game_rounds.includes(:darts).order(:created_at)
      turn_number = rounds.count

      progress_score = game.start_score
      score_sum = 0
      range_sum = 0
      stats = 0
      stats_darts = []
      rate_80 = false

      stats = 0
      game_range = nil
      target = nil
      target_darts = []
      game_analyzes = {}

      rounds.each_with_index do |round, r|
        round.darts.each_with_index do |dart, n|
          stats_darts << dart
          if dart.segment == 50
            score_sum += dart.segment
          else
            score_sum += dart.segment * dart.multiplier_before_type_cast
          end
          range_sum += dart.absolute_r
          #80%スタッツ
          if progress_score - score_sum <= judge_score
            total_darts_count = (r * 3) + (n + 1)
            stats = (score_sum.to_f / total_darts_count) * 3

            target_hashes = stats_darts.group_by(&:target)
            target, target_darts = target_hashes.max_by { |_, v| v.size }
            game_analyzes = calc.analysis_columns_for_game(target_darts)
            if target == "bull"
              game_range = (range_sum.to_f / total_darts_count).round(2)
            end
            rate_80 = true
            break
          end
          break if rate_80
        end
      end
      game.update!(
        {
          finished: true,
          stats: stats.round(2),
          range: game_range,
          turn_number: turn_number,
          sample_number: target_darts.size,
          sample_target: target
        }.merge(game_analyzes)
      )

      render json: {
        status: "ok",
        redirect_url: game_path(game.id)
      }
    else
      render json: { status: "ok" }
    end
  end
end
