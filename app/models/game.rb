class Game < ApplicationRecord
  belongs_to :user
  has_many :game_rounds

  before_create :set_number

  enum kind: { zero_one: 0, cricket: 1 }

  def set_number
    self.number = user.games.maximum(:number).to_i + 1
  end
end
