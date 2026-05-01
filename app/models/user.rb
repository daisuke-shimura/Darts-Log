class User < ApplicationRecord
  has_many :record_rounds
  
  enum gender: { other: 0, male: 1, female: 2 }

  def age
    return unless birthday
    now = Time.current
    age = now.year - birthday.year
    age -= 1 if now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)
  end

  def experience?
    experience.present? ? "〇" : "×"
  end
end
