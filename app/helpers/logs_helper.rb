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
end
