class Round < ApplicationRecord
  before_create :set_number

  def set_number
    self.number = user.posts.maximum(:number).to_i + 1
  end
end
