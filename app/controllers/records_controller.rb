class RecordsController < ApplicationController
  before_action :authenticate_user!
  layout "no-header", only: [:target]
  def index
    @defalut_target = "bull"
    @defalut_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
  end

  def create
    Rails.logger.debug "-----------------------------"
    darts = params[:results]
    hit = params[:hit]
    Rails.logger.debug darts.inspect

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    user_id = current_user.id
    record_round = RecordRound.create!(
      user_id: user_id,
      hit: hit,
    )

    darts.each_with_index do |dart, index|
      Dart.create!(
        record_round_id: record_round.id,
        segment: dart[:value],
        multiplier: dart[:multiplier],
        number: index + 1,
        absolute_r: dart[:absolute_r],
        absolute_0: dart[:absolute_0],
        index_r: dart[:r],
        index_n: dart[:n],
        target: dart[:target]
      )
    end
    render json: { status: "ok" }
  end
end
