class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.create!(
      user_id: current_user.id,
      kind: params[:kind],
      start_score: params[:start_score],
    )

    if game.kind == "zero_one"
      redirect_to game_zero_one_path(game.id)
    elsif game.kind == "cricket"
      redirect_to game_cricket_path(game.id)
    elsif game.kind == "count_up"
      redirect_to game_count_up_path(game.id)
    end
  end
end
