class LogsController < ApplicationController
  def index
    @target_groups = []

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

    if params[:targets].present?
      #@darts_data = @darts_data.where(target: params[:targets])
      params[:targets]&.each_with_index do |target, index|

        color = params[:colors][index].presence || "red"
        darts = Dart.where(target: target)
      
        @target_groups << {
          target: target,
          color: color,
          darts: darts
        }
      end
    end
  end
end
