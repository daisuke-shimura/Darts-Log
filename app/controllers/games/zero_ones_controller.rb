class Games::ZeroOnesController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @defalut_target = "bull"
    @defalut_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0
    darts = params[:results]
    bust = params[:bust]
    clear = params[:clear]
    created_darts = []

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    game_id = params[:game_id]
    record_round = GameRound.create!(
      game_id: game_id,
      bust: bust
    )

    darts.each_with_index do |dart, index|
      now_dart = Dart.create!(
        record_round_id: record_round.id,
        segment: dart[:segment],
        multiplier: dart[:multiplier],
        number: index + 1,
        absolute_r: dart[:absolute_r],
        absolute_0: dart[:absolute_0],
        index_r: dart[:r],
        index_n: dart[:n],
        target: dart[:target]
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
    record_round.update!(
      {
        hit: hit,
        s_bull: s_bull,
        d_bull: d_bull,
        score: score,
        range: range
      }.merge(awards)
    )

    if clear
      game = Game.find(game_id)
      judge_score = (game.start_score - 1) * 0.2
      rounds = game.game_rounds.order(:created_at)
      score_sum = 0
      status = 0
      rounds.each_with_index do |round, n|
        score_sum += round.score
        if score_sum >= judge_score
          status = score_sum.to_f / (n + 1)
          break
        end
      end
      turn_number = rounds.count
      game.update!(
        finished: true,
        stats: status,
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
