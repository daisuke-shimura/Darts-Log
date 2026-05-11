class Games::CricketCountUpsController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    # 続きから
    @current_score = 0
    rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @round_number = rounds.count + 1
    @round_marks = []
  end
end
