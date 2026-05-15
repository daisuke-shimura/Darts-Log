class LogsController < ApplicationController
  def index
    @Record_darts = Dart.where.not(record_round_id: nil)
    @Record_join = Dart.all.joins(:record_round)
    @Game_darts = Dart.where.not(game_round_id: nil)
    @Game_all = Dart.all

    game_data = Dart.none
    record_data = Dart.none
  
    if params[:kinds].present?
      game_data = Dart
        .joins(game_round: :game)
        .where(
          games: {
            kind: params[:kinds]
          }
        )
    end
  
    if params[:record] == "1"
      record_data = Dart.joins(:record_round)
    end
  
    if params[:kinds].blank? && params[:record].blank?
      @darts_data = Dart.all
    elsif params[:kinds].present? && params[:record] == "1"
      @darts_data = game_data.to_a | record_data.to_a
    else
      @darts_data = game_data.presence || record_data
    end
  end
end
