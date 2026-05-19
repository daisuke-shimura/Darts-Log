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
    recent_rounds = RecordRound.joins(:darts)
      .where(darts: { target: "bull" })
      .distinct
      .order(created_at: :asc)

    # X軸のラベル（例: R1, R2...）
    @line_labels = recent_rounds.map { |r| "R#{r.number}" }

    # Y軸のデータ（HIT数）
    @line_data = recent_rounds.map(&:hit)
  end

  def histogram
    darts = Dart.where(target: "bull")
    histogram_data = {
      "0〜16" => 0,
      "17〜40" => 0,
      "41〜54" => 0,
      "55〜65" => 0,
      "66〜84" => 0,
      "85〜109" => 0,
      "110〜130" => 0,
      "131〜150" => 0,
      "151〜173" => 0,
      "174〜196" => 0,
      "197〜392" => 0,
      "393〜465" => 0
    }
    darts.each do |dart|
      r = dart.absolute_r # 整数

      case r
      when 0..16
        histogram_data["0〜16"] += 1
      when 17..40
        histogram_data["17〜40"] += 1
      when 41..54
        histogram_data["41〜54"] += 1
      when 55..65
        histogram_data["55〜65"] += 1
      when 66..84
        histogram_data["66〜84"] += 1
      when 85..109
        histogram_data["85〜109"] += 1
      when 110..130
        histogram_data["110〜130"] += 1
      when 131..150
        histogram_data["131〜150"] += 1
      when 151..173
        histogram_data["151〜173"] += 1
      when 174..196
        histogram_data["174〜196"] += 1
      when 197..392
        histogram_data["197〜392"] += 1
      when 393..465
        histogram_data["393〜465"] += 1
      end
    end

    @bar_labels = histogram_data.keys
    @bar_data = histogram_data.values
  end
end
