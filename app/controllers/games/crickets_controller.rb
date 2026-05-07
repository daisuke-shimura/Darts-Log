class Games::CricketsController < ApplicationController
  def new
  end
  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    # 続きから
    cricket_segments = [20, 19, 18, 17, 16, 15, 50]
    rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @round_number = rounds.count + 1
    @current_segments_status = cricket_segments.index_with(0)
    @round_marks = []
    rounds.each_with_index do |round, r|
      @round_marks[r] = []
      round.darts.each_with_index do |dart, n|
        if @current_segments_status.key?(dart.segment)
          marks = case dart.multiplier
                  when "triple" then 3
                  when "double" then 2
                  else 1
                  end
          current = @current_segments_status[dart.segment]
          if current + marks > 3
            marks = 3 - current
          end
          @current_segments_status[dart.segment] += marks
          @round_marks[r][n] = marks
        end
      end
    end
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0
    darts = params[:results]
    mark = params[:mark]
    stats_judge = ActiveRecord::Type::Boolean.new.cast(params[:stats_judge])
    clear = ActiveRecord::Type::Boolean.new.cast(params[:clear])
    created_darts = []

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    game_id = params[:game_id]
    game_round = GameRound.create!(
      game_id: game_id,
      mark: mark,
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

    score, range = calc.score_and_range(created_darts)
    awards = calc.award(created_darts, score)
    game_round.update!(
      {
        hit: hit,
        s_bull: s_bull,
        d_bull: d_bull,
        score: score,
        range: range
      }.merge(awards)
    )

    if stats_judge
      game = Game.find(game_id)
      rounds = game.game_rounds.order(:created_at)
      total_mark = rounds.sum(:mark)
      stats = (total_mark.to_f / rounds.count).round(2)
      game.update!(
        stats: stats
      )
    end

    if clear
      game = Game.find(game_id)
      rounds = game.game_rounds.order(:created_at)
      turn_number = rounds.count
      game.update!(
        finished: true,
        turn_number: turn_number
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
