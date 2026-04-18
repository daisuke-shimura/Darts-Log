class RecordsController < ApplicationController
  before_action :authenticate_user!
  def index
    
  end

  def create
    Rails.logger.debug "-----------------------------"
    darts = params[:results]
    Rails.logger.debug darts.inspect

    if darts.size > 3
      render json: { error: "3つまでです" }, status: :unprocessable_entity
      return
    end

    user_id = current_user.id
    Round.create!(user_id: user_id)

    darts.each_with_index do |dart, index|
      Dart.create!(
        round_id: Round.last.id,
        segment: dart[:value],
        multiplier: dart[:multiplier],
        number: index + 1,
        absolute_r: dart[:absolute_r],
        absolute_0: dart[:absolute_0],
        index_r: dart[:r],
        index_n: dart[:n],
      )
    end
    render json: { status: "ok" }
  end
end
