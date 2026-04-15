class RecordsController < ApplicationController
  before_action :authenticate_user!
  def index
    
  end

  def create
    Rails.logger.debug "-----------------------------"
    Rails.logger.debug "-----------------------------"
    Rails.logger.debug params[:results]
    render json: { status: "ok" }
    # points = params[:points] || []

    # if points.size > 3
    #   render json: { error: "3つまでです" }, status: :unprocessable_entity
    #   return
    # end

    # user_id = current_user.id
    # Round.create!(user_id: user_id)

    # points.each_with_index do |p, index|
    #   Dart.create!(
    #     round_id: Round.last.id,
    #     segment: p[:value],
    #     multiplier: p[:multiplier],
    #     number: index + 1,
    #     relative_x: p[:x],
    #     relative_y: p[:y],
    #   )
    # end

    # console.log(points)
  
    # render json: { status: "ok" }
  end
end
