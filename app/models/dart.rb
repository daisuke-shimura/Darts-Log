class Dart < ApplicationRecord
  validate :parent_presence
  before_validation :normalize_absolute_0
  belongs_to :record_round, optional: true
  belongs_to :game_round, optional: true

  enum multiplier: { out: 0, single: 1, double: 2, triple: 3 }
  enum target: {
    bull: 50,
    t1: 301, t2: 302, t3: 303, t4: 304, t5: 305, t6: 306, t7: 307, t8: 308, t9: 309, t10: 310, t11: 311, t12: 312, t13: 313, t14: 314, t15: 315, t16: 316, t17: 317, t18: 318, t19: 319, t20: 320,
    d1: 201, d2: 202, d3: 203, d4: 204, d5: 205, d6: 206, d7: 207, d8: 208, d9: 209, d10: 210, d11: 211, d12: 212, d13: 213, d14: 214, d15: 215, d16: 216, d17: 217, d18: 218, d19: 219, d20: 220,
    s1: 101, s2: 102, s3: 103, s4: 104, s5: 105, s6: 106, s7: 107, s8: 108, s9: 109, s10: 110, s11: 111, s12: 112, s13: 113, s14: 114, s15: 115, s16: 116, s17: 117, s18: 118, s19: 119, s20: 120,
    undefined: 0,
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
