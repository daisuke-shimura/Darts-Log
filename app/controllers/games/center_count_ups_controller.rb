class Games::CenterCountUpsController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    # 続きから
    @rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @round_number = @rounds.count + 1
    @current_score = @rounds.sum(&:score)
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0
    darts = params[:results]
    created_darts = []
    center_count_up = [
      { max: 16.6, score: 600 },
      { max: 40.0, score: 500 },
      { max: 54.6, score: 480 },
      { max: 65.9, score: 400 },
      { max: 84.8, score: 350 },
      { max: 109.0, score: 200 },
      { max: 130.4, score: 100 },
      { max: 150.2, score: 80 },
      { max: 173.8, score: 70 },
      { max: 196.0, score: 60 },
      { max: 392.6, score: 50 },
      { max: 478.0, score: 0 }
    ]

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    game = Game.find(params[:game_id])
    game_round = GameRound.create!(
      game_id: game.id
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

    score = 0
    range_sum = 0
    created_darts.each do |dart|
      score += center_count_up.find { |c| dart.absolute_r <= c[:max] }[:score]
      range_sum += dart.absolute_r
    end

    range = (range_sum.to_f / created_darts.size).round(2)
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

    # ゲーム終了の判定
    if game.game_rounds.count >= 8
      rounds = game.game_rounds.includes(:darts).order(:created_at)

      score_sum = rounds.sum(&:score)
      turn_number = rounds.count
      stats = (score_sum / turn_number).round(2)

      darts = rounds.flat_map(&:darts)
      target_hashes = darts.group_by(&:target)
      target, target_darts = target_hashes.max_by { |_, v| v.size }
      _, game_range = calc.score_and_range(target_darts)
      game_analyzes = calc.analysis_columns_for_game(target_darts)

      game.update!(
        {
          finished: true,
          stats: stats,
          score: score_sum,
          range: game_range,
          turn_number: turn_number,
          sample_number: target_darts.size,
          sample_target: target
        }.merge(game_analyzes)
      )

      render json: {
        status: "ok",
        redirect_url: root_path
      }
    else
      render json: { status: "ok" }
    end
  end
end
