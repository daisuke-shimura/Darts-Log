class Games::ZeroOnesController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
  end

  def show
    @game = Game.find(params[:game_id])
    @defalut_target = "bull"
    @defalut_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
  end

  def create

  end
end
