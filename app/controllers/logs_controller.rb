class LogsController < ApplicationController
  def index
    @darts_all = Dart.all
    @target_bull = @darts_all.where(target: "bull")
    @target_20 = @darts_all.where(target: "t20")
    @round_darts = @darts_all.where.not(game_round_id: nil)
    @game_darts = @darts_all.joins(game_round: :game)
    @zero_one_darts = @game_darts.where(games: { kind: "zero_one" })
    @cricket_darts = @game_darts.where(games: { kind: "cricket" })
    @count_up_darts = @game_darts.where(games: { kind: "count_up" })
    @center_count_up_darts = @game_darts.where(games: { kind: "center_count_up" })
    @cricket_count_up_darts = @game_darts.where(games: { kind: "cricket_count_up" })
    @shoot_out_darts = @game_darts.where(games: { kind: "shoot_out" })
    @first_darts = @darts_all.where(number: 1)
    @second_darts = @darts_all.where(number: 2)
    @third_darts = @darts_all.where(number: 3)

    @target_groups = []
    @game_labels = {
      "zero_one" => {  label: "01",  color: "danger"},
      "cricket" => {  label: "CRICKET",  color: "primary"},
      "count_up" => {  label: "COUNT-UP",  color: "success"},
      "center_count_up" => {  label: "CENTER COUNT-UP",  color: "warning"},
      "cricket_count_up" => {  label: "CRICKET COUNT-UP",  color: "info"},
      "shoot_out" => {  label: "SHOOT OUT",  color: "dark"}
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
      id = game_data.ids | record_data.ids
      @darts_data = Dart.where(id: id)
    else
      @darts_data = game_data.presence || record_data
    end

    if params[:numbers].present?
      @darts_data = @darts_data.where(number: params[:numbers])
    end

    if params[:targets].present?
      target_darts = []
      params[:targets].each_with_index do |target, index|

        color = params[:colors][index].presence || "red"
        darts = @darts_data.where(target: target)
  
        darts.each do |dart|
          dart.color = color
        end

        target_darts.concat(darts)
      end
      @darts_data = target_darts
    end
  end

  def line_graph
    # デモデータ
    @line_labels = ['1月', '2月', '3月', '4月', '5月']
    @line_data = [100, 150, 200, 120, 250]
  end

  def histogram
    # デモデータ
    histogram_data = { '0-20点' => 5, '21-40点' => 12, '41-60点' => 25, '61-80点' => 38, '81-100点' => 15 }
    @bar_labels = histogram_data.keys
    @bar_data = histogram_data.values
  end
end
