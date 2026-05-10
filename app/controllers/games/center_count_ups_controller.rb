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
    @current_score = @rounds.where(bust: false).sum(:score)
  end

  def create
    
  end
end
