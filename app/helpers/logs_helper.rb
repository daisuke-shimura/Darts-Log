module LogsHelper
  def target_sort
    targets = []

    targets << "bull"
    targets += (1..20).reverse_each.map { |n| "t#{n}" }
    targets += (1..20).reverse_each.map { |n| "d#{n}" }
    targets += (1..20).reverse_each.map { |n| "s#{n}" }
    targets << "undefined"

    targets
  end

  def darts_number_color(throw)
    if params[:numbers].present?
      number_colors = { 1 => "red", 2 => "blue", 3 => "green" }
      number_colors[throw.number]
    else
      throw.color.presence || "red"
    end
  end

  def bull_count(darts)
    darts.count { |dart| dart.absolute_r < 41 }
  end

  def bull_count_of_number(darts, number)
    darts.count do |dart|
      dart.number.to_s == number.to_s && dart.absolute_r < 41
    end
  end

  def sement_count(darts, target)
    return if target == "bull" || target == "undefined"
 
    rate = target[0]
    if rate == "t"
      multiplier = "triple"
    elsif rate == "d"
      multiplier = "double"
    elsif rate == "s"
      multiplier = "single"
    end

    segment = target[1..-1].to_i

    count = darts.count do |dart|
      dart.multiplier == multiplier && dart.segment == segment
    end

    "#{target}合計：#{count}"
  end

  # 状態遷移図
  # 自己ループのパスとテキスト座標を計算
  def loop_path_attributes(pos)
    node_x = pos[:x]
    node_y = pos[:y]
    angle  = pos[:angle]

    loop_length = 100
    cp1_x = node_x + loop_length * Math.cos(angle - 0.6)
    cp1_y = node_y + loop_length * Math.sin(angle - 0.6)
    cp2_x = node_x + loop_length * Math.cos(angle + 0.6)
    cp2_y = node_y + loop_length * Math.sin(angle + 0.6)

    text_x = node_x + (loop_length * 0.75) * Math.cos(angle)
    text_y = node_y + (loop_length * 0.75) * Math.sin(angle)

    {
      d: "M #{node_x} #{node_y} C #{cp1_x} #{cp1_y}, #{cp2_x} #{cp2_y}, #{node_x} #{node_y}",
      text_x: text_x,
      text_y: text_y
    }
  end

  # 他ノードへの遷移パスとテキスト座標を計算
  def transition_path_attributes(from_pos, to_pos)
    x1, y1 = from_pos[:x], from_pos[:y]
    x2, y2 = to_pos[:x], to_pos[:y]

    mx = (x1 + x2) / 2.0
    my = (y1 + y2) / 2.0
    dx = x2 - x1
    dy = y2 - y1
    dist = Math.sqrt(dx**2 + dy**2)

    # ゼロ除算回避（基本的には発生しませんが念のため）
    return { d: "", text_x: x1, text_y: y1 } if dist == 0

    nx = -dy / dist
    ny = dx / dist

    offset = 30
    cx = mx + nx * offset
    cy = my + ny * offset

    text_x = mx + nx * (offset / 2.0)
    text_y = my + ny * (offset / 2.0)

    {
      d: "M #{x1} #{y1} Q #{cx} #{cy} #{x2} #{y2}",
      text_x: text_x,
      text_y: text_y
    }
  end

  # 遷移数と最大値から、線の太さと色を10段階で決定する
  def transition_style(count, max_count, second_max)
    return { width: 2, color: arrow_marker_colors["arrow-1"], marker_id: "arrow-1" } if max_count.to_i == 0

    if count >= max_count
      # 【特別枠】最大値は完全に切り離してレベル10
      width = 10.0
      level = 10
    else
      # 2番目の最大値を基準（100%）とする
      safe_second = second_max.to_i > 0 ? second_max : 1
      ratio = count.to_f / safe_second
      
      # 1.0を超えた場合（あり得ないはずですが念のため）は1.0にする
      ratio = 1.0 if ratio > 1.0 

      # 太さは2px 〜 8px
      width = 2.0 + (6.0 * ratio)

      # 2番目の最大値をシンプルに9等分する
      level = (ratio * 9).ceil
      level = 1 if level < 1
      level = 9 if level > 9
    end

    marker_id = "arrow-#{level}"

    { marker_id: marker_id, width: width.round(1), color: arrow_marker_colors[marker_id] }
  end

  def arrow_marker_colors
    {
      "arrow-1"  => "#94a3b8",
      "arrow-2"  => "#0ea5e9",
      "arrow-3"  => "#10b981",
      "arrow-4"  => "#84cc16",
      "arrow-5"  => "#eab308",
      "arrow-6"  => "#f59e0b",
      "arrow-7"  => "#f97316",
      "arrow-8"  => "#ef4444",
      "arrow-9"  => "#b91c1c",
      "arrow-10" => "#7f1d1d"
    }
  end

  # 凡例の生成ロジックを修正
  def transition_legend(max_count, second_max)
    return [] if max_count.to_i == 0

    legend_groups = {}
    safe_second = second_max.to_i > 0 ? second_max : 1

    # 最大値は無視して、1から「2番目の最大値」までだけをループして9等分の凡例を作る
    (1..safe_second).each do |count|
      style = transition_style(count, max_count, safe_second)
      marker_id = style[:marker_id]
      legend_groups[marker_id] ||= { color: style[:color], counts: [] }
      
      legend_groups[marker_id][:counts] << count
    end

    # レベル1〜9の凡例テキストを作成
    legend_data = legend_groups.map do |marker_id, data|
      counts = data[:counts]
      min = counts.min
      max = counts.max
      text = min == max ? "#{min}回" : "#{min}〜#{max}回"
      { marker_id: marker_id, text: text, color: data[:color] }
    end

    # 最後に、最大値（レベル10）を独立した凡例として追加
    if max_count > safe_second
      max_color = arrow_marker_colors["arrow-10"]
      legend_data << { marker_id: "arrow-10", text: "#{max_count}回", color: max_color }
    end

    # 大きい順（暖色が上）になるように反転
    legend_data.reverse
  end

  def date_range(day_from, day_to)
    return if day_from.blank? && day_to.blank?

    if day_from.blank?
      from = "..."
    else
      from = Date.parse(day_from).strftime("%-m/%-d")
    end

    if day_to.blank?
      to = "..."
    else
      to = Date.parse(day_to).strftime("%-m/%-d")
    end

    if day_from == day_to
      from
    else
      "#{from}〜#{to}"
    end
  end
end
