class RecordsController < ApplicationController
  before_action :authenticate_user!
  layout "no-header", only: [:target]
  def index
    @defalut_target = "bull"
    @defalut_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
  end

  def create
    calc = RoundCalculator.new
    hit = 0
    s_bull = 0
    d_bull = 0

    Rails.logger.debug "-----------------------------"
    darts = params[:results]

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    user_id = current_user.id
    record_round = RecordRound.create!(
      user_id: user_id,
    )

    created_darts = []
    
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
    
    render json: { status: "ok" }
  end
end
