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

    mode = params[:histogram_mode] || "range"

    if mode == "exact"
      r_values = [
        0, 8, 15, 24, 29, 34, 40, 52, 58, 64, 69, 74, 77, 79, 82, 84, 87, 
        89, 92, 95, 97, 100, 102, 105, 107, 111, 112, 117, 122, 128, 133, 
        138, 144, 149, 155, 161, 166, 172, 177, 183, 189, 195, 201, 206, 
        219, 225, 231, 236, 241, 257, 262, 267, 272, 277, 283, 288, 293, 
        299, 304, 310, 316, 321, 326, 332, 337, 342, 348, 363, 369, 374, 
        380, 386, 401, 407, 413, 419, 425, 431
      ]
      db_counts = darts.group(:absolute_r).count

      histogram_data = r_values.index_with { |val| db_counts[val] || 0 }
    elsif mode == "exact_r"
      db_counts = darts.group(:index_r).count
      histogram_data = (0..69).index_with { |val| db_counts[val] || 0 }
    else 
      histogram_data = {
        "0〜42" => 0,
        "43〜85" => 0,
        "86〜128" => 0,
        "129〜171" => 0,
        "172〜214" => 0,
        "215〜257" => 0,
        "258〜300" => 0,
        "301〜343" => 0,
        "344〜386" => 0,
        "387〜431" => 0 #最後はちょっと多い
      }
    
      darts.each do |dart|
        r = dart.absolute_r
  
        case r
        when 0..42
          histogram_data["0〜42"] += 1
        when 43..85
          histogram_data["43〜85"] += 1
        when 86..128
          histogram_data["86〜128"] += 1
        when 129..171
          histogram_data["129〜171"] += 1
        when 172..214
          histogram_data["172〜214"] += 1
        when 215..257
          histogram_data["215〜257"] += 1
        when 258..300
          histogram_data["258〜300"] += 1
        when 301..343
          histogram_data["301〜343"] += 1
        when 344..386
          histogram_data["344〜386"] += 1
        when 387..431
          histogram_data["387〜431"] += 1
        end
      end
    end
    @bar_labels = histogram_data.keys
    @bar_data = histogram_data.values
  end
end
