class Games::CricketsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
  end

  def show
    @game = Game.find(params[:id])
  end
end
