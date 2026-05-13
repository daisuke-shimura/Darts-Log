class Game < ApplicationRecord
  belongs_to :user
  has_many :game_rounds, dependent: :destroy

  before_create :set_number

  enum kind: { zero_one: 0, cricket: 1, count_up: 2, center_count_up: 3, cricket_count_up: 4, shoot_out: 5 }
  enum sample_target: {
    bull: 50,
    t1: 301, t2: 302, t3: 303, t4: 304, t5: 305, t6: 306, t7: 307, t8: 308, t9: 309, t10: 310, t11: 311, t12: 312, t13: 313, t14: 314, t15: 315, t16: 316, t17: 317, t18: 318, t19: 319, t20: 320,
    d1: 201, d2: 202, d3: 203, d4: 204, d5: 205, d6: 206, d7: 207, d8: 208, d9: 209, d10: 210, d11: 211, d12: 212, d13: 213, d14: 214, d15: 215, d16: 216, d17: 217, d18: 218, d19: 219, d20: 220,
    s1: 101, s2: 102, s3: 103, s4: 104, s5: 105, s6: 106, s7: 107, s8: 108, s9: 109, s10: 110, s11: 111, s12: 112, s13: 113, s14: 114, s15: 115, s16: 116, s17: 117, s18: 118, s19: 119, s20: 120,
    undefined: 0,
  }

  def set_number
    self.number = user.games.maximum(:number).to_i + 1
  end
end
