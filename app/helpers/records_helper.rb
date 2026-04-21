module RecordsHelper
  def bull_top_standard(index_number, division_number)
    (90 - (index_number - 1) * (360.0 / division_number) + 360) % 360
  end

  def bull_zero_standard(index_number, division_number, zero_number)
    #(((zero_number - 1) - (index_number - 1) + division_number) % division_number) * (360.0 / division_number)
    ((zero_number - index_number + division_number) % division_number) * (360.0 / division_number)
  end

end
