class LogsController < ApplicationController
  layout "logs"
  before_action :set_r_values, only: [:histogram, :cumulative, :rayleigh]
  before_action :load_calendar, only: [:index]

  def index
    @darts_all = Dart.all
    @target_bull = @darts_all.where(target: "bull")
    @target_20 = @darts_all.where(target: "t20")
    @record_darts = @darts_all.where(game_round_id: nil)
    @record_rounds = @record_darts.distinct.count(:record_round_id)
    @game_darts = @darts_all.where(record_round_id: nil).joins(game_round: :game)
    @game_rounds = @game_darts.distinct.count(:game_round_id)
    @game = @game_darts.distinct.count(:game_id)
    @zero_one_darts = @game_darts.where(games: { kind: "zero_one" })
    @zero_one_games = @zero_one_darts.distinct.count(:game_id)
    @cricket_darts = @game_darts.where(games: { kind: "cricket" })
    @cricket_games = @cricket_darts.distinct.count(:game_id)
    @count_up_darts = @game_darts.where(games: { kind: "count_up" })
    @count_up_games = @count_up_darts.distinct.count(:game_id)
    @center_count_up_darts = @game_darts.where(games: { kind: "center_count_up" })
    @center_count_up_games = @center_count_up_darts.distinct.count(:game_id)
    @cricket_count_up_darts = @game_darts.where(games: { kind: "cricket_count_up" })
    @cricket_count_up_games = @cricket_count_up_darts.distinct.count(:game_id)
    @shoot_out_darts = @game_darts.where(games: { kind: "shoot_out" })
    @shoot_out_games = @shoot_out_darts.distinct.count(:game_id)
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

    @darts_data = filter_by_time(@darts_data)

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
    @recent_rounds = filter_by_time(
                      RecordRound.joins(:darts)
                      .where(darts: { target: "bull" })
                      .distinct
                      .order(created_at: :asc)
                    )

    # X軸のラベル（例: R1, R2...）
    @line_labels = @recent_rounds.map { |r| "R#{r.number}" }

    # HIT数
    @hit_data = @recent_rounds.map(&:hit)
    # 平均距離
    @grouping_data = @recent_rounds.map(&:gravity_distance_ave)

    # 重心のR
    @gravity_r_data = @recent_rounds.map do |round|
      Math.sqrt(
        round.gravity_center_x ** 2 +
        round.gravity_center_y ** 2
      ).round(2)
    end

    # X分散
    @variance_x_data = @recent_rounds.map(&:variance_x)

    # Y分散
    @variance_y_data = @recent_rounds.map(&:variance_y)

    @graph_data = [
      {
        label: "BULL数",
        data: @hit_data,
        color: "rgb(75, 192, 192)",
        axis: "hit"
      },
      {
        label: "平均距離",
        data: @grouping_data,
        color: "rgb(54, 162, 235)",
        axis: "distance"
      },
      {
        label: "重心のR",
        data: @gravity_r_data,
        color: "rgb(153, 102, 255)",
        axis: "gravity_r"
      },
      {
        label: "X分散",
        data: @variance_x_data,
        color: "rgb(255, 159, 64)",
        axis: "variance_x"
      },
      {
        label: "Y分散",
        data: @variance_y_data,
        color: "rgb(255, 205, 86)",
        axis: "variance_y"
      }
    ]
  end

  def histogram
    @darts = filter_by_time(Dart.where(target: "bull"))

    @histogram_modes = {
      range: "幅43",
      exact: "実値",
      exact_r: "実値（R）"
    }

    mode = params[:histogram_mode] || "range"

    if mode == "exact"
      db_counts = @darts.group(:absolute_r).count
      histogram_data = @r_values.index_with { |val| db_counts[val] || 0 }
    elsif mode == "exact_r"
      db_counts = @darts.group(:index_r).count
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
    
      @darts.each do |dart|
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

  def cumulative
    cumulative_data = set_cumulative_data

    @modes = {
      absolute_r: "直径",
      index_r: "R"
    }

    @bar_labels = cumulative_data.keys
    @bar_data = cumulative_data.values
  end

  def rayleigh
    cumulative_data = set_cumulative_data

    @modes = {
      absolute_r: "直径",
      index_r: "R"
    }

    mode = params[:mode] || "absolute_r"
    if mode == "index_r"
      rayleigh_data = cumulative_data.map do |r, f|
        next if f >= 1.0
    
        [
          r ** 2,
          -Math.log(1 - f)
        ]
      end.compact.to_h
    else
      rayleigh_data = cumulative_data.map do |r, f|
        next if f >= 1.0
    
        radius = r / 2.0
        [
          radius ** 2,
          -Math.log(1 - f)
        ]
      end.compact.to_h
    end

    @bar_labels = rayleigh_data.keys
    @bar_data = rayleigh_data.values
  end

  def state_transition
    @recent_rounds = filter_by_time(
      RecordRound.joins(:darts)
      .where(darts: { target: "bull" })
      .distinct
      .order(created_at: :asc)
    )

    states_frow = []
    @patterns = {
      "000" => 0,
      "100" => 0,
      "010" => 0,
      "001" => 0,
      "110" => 0,
      "101" => 0,
      "011" => 0,
      "111" => 0
    }
    @recent_rounds.each do |round|
      state = ["0","0","0"]

      round.darts.each do |dart|
        state[dart.number - 1] = "1" if dart.segment == 50
      end

      states_frow << state.join
      @patterns[state.join] += 1
    end

    @states = %w[
      000
      100
      010
      001
      110
      101
      011
      111
    ]

    @transitions = {}

    @states.each do |from|
      @states.each do |to|
        @transitions[[from, to]] = 0
      end
    end

    states_frow.each_cons(2) do |from, to|
      @transitions[[from, to]] += 1
    end

    @max_transition = @transitions.values.max
    @second_max_transition = @transitions.values.uniq.max(2)[1]

    center_x = 400
    center_y = 275
    radius = 225
  
    angles = {
      "000" => 0,   "110" => 45,  "101" => 90,  "011" => 135,
      "111" => 180, "001" => 225, "010" => 270, "100" => 315
    }
  
    @positions = angles.transform_values do |degree|
      radian = degree * Math::PI / 180
      x = (center_x + radius * Math.sin(radian)).round
      y = (center_y - radius * Math.cos(radian)).round
      
      angle = Math.atan2(y - center_y, x - center_x)
  
      { x: x, y: y, angle: angle }
    end
  end


  private

  def set_r_values
    @r_values = [
      0, 8, 15, 24, 29, 34, 40, 52, 58, 64, 69, 74, 77, 79, 82, 84, 87, 
      89, 92, 95, 97, 100, 102, 105, 107, 111, 112, 117, 122, 128, 133, 
      138, 144, 149, 155, 161, 166, 172, 177, 183, 189, 195, 201, 206, 
      219, 225, 231, 236, 241, 257, 262, 267, 272, 277, 283, 288, 293, 
      299, 304, 310, 316, 321, 326, 332, 337, 342, 348, 363, 369, 374, 
      380, 386, 401, 407, 413, 419, 425, 431
    ]
  end

  def set_cumulative_data
    @darts = filter_by_time(Dart.where(target: "bull"))
    # @darts = Dart.where(target: "bull")
    n = @darts.count
    cumulative = 0.0

    mode = params[:mode] || "absolute_r"
    if mode == "index_r"
      db_counts = @darts.group(:index_r).count
      cumulative_data = (0..69).index_with do |r|
        count = db_counts[r] || 0
        cumulative += count
        cumulative.to_f / n
      end
    else
      db_counts = @darts.group(:absolute_r).count
      cumulative_data = @r_values.index_with do |r|
        count = db_counts[r] || 0
        cumulative += count
        cumulative.to_f / n
      end
    end

    return cumulative_data
  end

  def filter_by_time(scope)
    table = scope.model.table_name

    if params[:day_from].present?
      scope = scope.where(
        "#{table}.created_at >= ?",
        Date.parse(params[:day_from]).beginning_of_day
      )
    end
  
    if params[:day_to].present?
      scope = scope.where(
        "#{table}.created_at <= ?",
        Date.parse(params[:day_to]).end_of_day
      )
    end
  
    if params[:recent].present?
      scope = scope.order("#{table}.created_at DESC")
                   .limit(params[:recent].to_i)
    end
  
    scope
  end

  def load_calendar
    if params[:month].present?
      @target_month = Date.strptime(params[:month], "%Y-%m")
    else
      @target_month = Date.current
    end
    @start_date = @target_month.beginning_of_month
    @end_date   = @target_month.end_of_month
    start_day = @start_date.beginning_of_week(:sunday)
    end_day = @end_date.end_of_week(:sunday)
    @calendar_dates = (start_day..end_day).to_a

    @daily_darts = Rails.cache.fetch(
        "calendar/#{@target_month.strftime('%Y-%m')}",
        expires_in: 1.hour
      ) do
        Dart.select(:created_at, :target, :segment)
            .where(created_at: start_day.beginning_of_day..end_day.end_of_day)
            .group_by { |dart| dart.created_at.to_date }
      end
    # @daily_darts = Dart.where(created_at: start_day.beginning_of_day..end_day.end_of_day).group_by { |dart| dart.created_at.to_date }
  end
end
