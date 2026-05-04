class GameRound < ApplicationRecord
  belongs_to :game
  has_many :darts, dependent: :destroy
end
