class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.create!(
      user_id: current_user.id,
      kind: params[:kind],
      start_score: params[:start_score],
    )

    if game.kind == "cricket"
      redirect_to games_crickets_path(game_id: game.id)
    else
      redirect_to games_zero_ones_path(game_id: game.id)
    end
  end
end
