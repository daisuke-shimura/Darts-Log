class Games::CricketCountUpsController < ApplicationController
  CRICKET_SEGMENTS = [20, 19, 18, 17, 16, 15, 50]
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    # 続きから
    rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @current_score = rounds.sum(&:score)
    @round_number = rounds.count + 1
    @round_marks = []
    rounds.each_with_index do |round, i|
      round_mark = []
      round.darts.each do |dart|
        if valid_segment?((i + 1), dart.segment)
          mark = mark_value(dart.multiplier)
        else
          mark = 0
        end
        round_mark << mark
      end
      @round_marks << round_mark
    end
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0
    darts = params[:results]
    created_darts = []

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

    round_count = game.game_rounds.count
    score = 0
    range_sum = 0
    mark_sum = 0

    created_darts.each do |dart|
      if valid_segment?(round_count, dart.segment)
        mark = mark_value(dart.multiplier)
      else
        mark = 0
      end

      if dart.segment == 50
        if mark == 2
          score += 50
        elsif mark == 1
          score += 25
        else
          score += 0
        end
      else
        score += dart.segment * mark
      end
      range_sum += dart.absolute_r
      mark_sum += mark
    end
    range = (range_sum.to_f / created_darts.size).round(2)

    awards = calc.award(created_darts, score)
    analysis = calc.analysis_columns(created_darts)
    game_round.update!(
      {
        score: score,
        mark: mark_sum,
        hit: hit,
        range: range,
        s_bull: s_bull,
        d_bull: d_bull
      }.merge(awards).merge(analysis)
    )

    # ゲーム終了の判定
    if round_count >= 8
      rounds = game.game_rounds.includes(:darts).order(:created_at)
      score_sum = rounds.sum(&:score)
      mark_sum = rounds.sum(&:mark)
      turn_number = rounds.count
      stats = (mark_sum / turn_number).round(2)

      game.update!(
        {
          finished: true,
          stats: stats,
          score: score_sum,
          turn_number: turn_number
        }
      )

      render json: {
        status: "ok",
        redirect_url: root_path
      }
    else
      render json: { status: "ok" }
    end
  end

  private
  def valid_segment?(round_number, segment)
    if round_number >= 1 && round_number <= 7
      segment == CRICKET_SEGMENTS[round_number - 1]
    elsif round_number == 8
      CRICKET_SEGMENTS.include?(segment)
    else
      false
    end
  end

  def mark_value(multiplier)
    if multiplier == "triple"
      mark = 3
    elsif multiplier == "double"
      mark = 2
    elsif multiplier == "single"
      mark = 1
    else
      mark = 0
    end
    return mark
  end
end
