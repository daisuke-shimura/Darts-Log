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

  def darts_number_color(throw, default_color)
    if params[:numbers].present?
      number_colors = { 1 => "red", 2 => "blue", 3 => "green" }
      number_colors[throw.number]
    else
      default_color
    end
  end
end
