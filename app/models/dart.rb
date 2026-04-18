class Dart < ApplicationRecord
  belongs_to :round
  
  enum segument: { bull: 0 }
  enum multiplier: { out: 0, single: 1, double: 2, triple: 3 }
end
