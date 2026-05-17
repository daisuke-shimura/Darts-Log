class LogsController < ApplicationController
  def index
    @darts_all = Dart.all
    @target_bull = @darts_all.where(target: "bull")
    @target_20 = @darts_all.where(target: "20")
    @round_darts = @darts_all.where.not(game_round_id: nil)
    @game_darts = @darts_all.joins(game_round: :game)
    @zero_one_darts = @game_darts.where(games: { kind: "zero_one" })
    @cricket_darts = @game_darts.where(games: { kind: "cricket" })
    @count_up_darts = @game_darts.where(games: { kind: "count_up" })
    @center_count_up_darts = @game_darts.where(games: { kind: "center_count_up" })
    @cricket_count_up_darts = @game_darts.where(games: { kind: "cricket_count_up" })
    @shoot_out_darts = @game_darts.where(games: { kind: "shoot_out" })

    @target_groups = []
    @game_labels = {
      "zero_one" => {
        label: "01",
        color: "danger"
      },
      "cricket" => {
        label: "CRICKET",
        color: "primary"
      },
      "count_up" => {
        label: "COUNT-UP",
        color: "success"
      },
      "center_count_up" => {
        label: "CENTER COUNT-UP",
        color: "warning"
      },
      "cricket_count_up" => {
        label: "CRICKET COUNT-UP",
        color: "info"
      },
      "shoot_out" => {
        label: "SHOOT OUT",
        color: "dark"
      }
    }
    @selected_kinds = @game_labels.select do |key, _|
      params[:kinds]&.include?(key)
    end

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
      #@darts_data = game_data.to_a | record_data.to_a
      id = game_data.ids | record_data.ids
      @darts_data = Dart.where(id: id)
    else
      @darts_data = game_data.presence || record_data
    end

    if params[:targets].present?
      params[:targets]&.each_with_index do |target, index|

        color = params[:colors][index].presence || "red"
        darts = @darts_data.where(target: target)
      
        @target_groups << {
          target: target,
          color: color,
          darts: darts
        }
      end
    end
  end
end
