class Round < ApplicationRecord
  belongs_to :user
  has_many :darts, dependent: :destroy

  before_create :set_number

  def set_number
    self.number = user.rounds.maximum(:number).to_i + 1
  end
end
