class Dart < ApplicationRecord
  before_validation :normalize_absolute_0
  belongs_to :round

  enum segument: { bull: 0 }
  enum multiplier: { out: 0, single: 1, double: 2, triple: 3 }

  def normalize_absolute_0
    self.absolute_0 = absolute_0.to_d.round(2) if absolute_0.present?
  end
end
