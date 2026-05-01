class Dart < ApplicationRecord
  validate :parent_presence
  before_validation :normalize_absolute_0
  belongs_to :record_round, optional: true
  belongs_to :game_round, optional: true

  enum multiplier: { out: 0, single: 1, double: 2, triple: 3 }
  enum target: {
    bull: 0,
    t1: 1,  t2: 2,  t3: 3,  t4: 4,  t5: 5,  t6: 6,  t7: 7,  t8: 8,  t9: 9,  t10: 10, t11: 11, t12: 12, t13: 13, t14: 14, t15: 15, t16: 16, t17: 17, t18: 18, t19: 19, t20: 20,
    d1: 21, d2: 22, d3: 23, d4: 24, d5: 25, d6: 26, d7: 27, d8: 28, d9: 29, d10: 30, d11: 31, d12: 32, d13: 33, d14: 34, d15: 35, d16: 36, d17: 37, d18: 38, d19: 39, d20: 40,
    s1: 41, s2: 42, s3: 43, s4: 44, s5: 45, s6: 46, s7: 47, s8: 48, s9: 49, s10: 50, s11: 51, s12: 52, s13: 53, s14: 54, s15: 55, s16: 56, s17: 57, s18: 58, s19: 59, s20: 60,
    undefined: 255,
  }

  def normalize_absolute_0
    self.absolute_0 = absolute_0.to_d.round(2) if absolute_0.present?
  end

  def segment_label
    self.segment == 50 ? "BULL" : self.segment.to_s
  end

  def parent_presence
    if record_round_id.blank? && game_round_id.blank?
      errors.add(:base, "親が必要")
    elsif record_round_id.present? && game_round_id.present?
      errors.add(:base, "どちらか一方にしてください")
    end
  end
end
