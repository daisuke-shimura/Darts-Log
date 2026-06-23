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

    {
      width: width.round(1),
      color: arrow_marker_colors[marker_id],
      marker_id: marker_id
    }
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
      color = transition_style(count, max_count, safe_second)[:color]
      legend_groups[color] ||= []
      legend_groups[color] << count
    end

    # レベル1〜9の凡例テキストを作成
    legend_data = legend_groups.map do |color, counts|
      min = counts.min
      max = counts.max
      text = min == max ? "#{min}回" : "#{min}〜#{max}回"
      { color: color, text: text }
    end

    # 最後に、最大値（レベル10）を独立した凡例として追加
    if max_count > safe_second
      max_color = arrow_marker_colors["arrow-10"]
      legend_data << { color: max_color, text: "#{max_count}回" }
    end

    # 大きい順（暖色が上）になるように反転
    legend_data.reverse
  end
end
