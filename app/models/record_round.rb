class RecordRound < ApplicationRecord
  belongs_to :user
  has_many :darts, dependent: :destroy

  enum condition: { normal: 0, blindfold: 1, right_eye: 2, left_eye: 3 }

  before_create :set_number

  def set_number
    self.number = user.record_rounds.maximum(:number).to_i + 1
  end
end
