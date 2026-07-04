class Games::ShootOutsController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    @rate = 1
    # 続きから
    shoot_segments = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,50]
    @rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @round_number = @rounds.count + 1
    @current_score = @rounds.sum(&:score)
    @current_segments_status = shoot_segments.index_with(0)
    @rounds.each_with_index do |round|
      round.darts.each_with_index do |dart, n|
        if @current_segments_status[dart.segment] == 0
          @current_segments_status[dart.segment] = dart.segment * dart.multiplier_before_type_cast * @rate
          @rate += 1
        end
      end
    end
    @closed_segments = [
      [nil, 17, 13,  9,  5,  1],
      [nil, 18, 14, 10,  6,  2],
      [nil, 19, 15, 11,  7,  3],
      [ 50, 20, 16, 12,  8,  4],
    ]
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
  
    score_sum = 0
    range_sum = 0

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
      score_sum += dart[:score]
      range_sum += now_dart.absolute_r

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

    range = (range_sum.to_f / created_darts.size).round(2)
    analysis = calc.analysis_columns(created_darts)

    # ゲーム終了の判定
    if game.game_rounds.count >= 8
      # roundのupdate
      awards = hat_trick(created_darts)
      game_round.update!(
        {
          score: score_sum,
          hit: hit,
          range: range,
          s_bull: s_bull,
          d_bull: d_bull
        }.merge(awards).merge(analysis)
      )

      # gameのupdate
      rounds = game.game_rounds.order(:created_at)
      score_sum = rounds.sum(:score)
      turn_number = rounds.count

      game.update!(
        {
          finished: true,
          score: score_sum,
          turn_number: turn_number
        }
      )

      render json: {
        status: "ok",
        redirect_url: game_path(game.id)
      }
    else
      game_round.update!(
        {
          score: score_sum,
          hit: hit,
          range: range,
          s_bull: s_bull,
          d_bull: d_bull
        }.merge(analysis)
      )

      render json: { status: "ok" }
    end
  end

  private
  def hat_trick(round)
    awards = {
      hat_trick: false,
      three_in_the_black: false
    }

    return awards if round.size < 3

    first = round[0]
    second = round[1]
    third = round[2]
    if first.segment == 50 && second.segment == 50 && third.segment == 50
      awards[:hat_trick] = true
      if first.double? && second.double? && third.double?
        awards[:three_in_the_black] = true
      end
    end
    return awards
  end
end
