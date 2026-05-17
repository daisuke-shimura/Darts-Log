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
end
