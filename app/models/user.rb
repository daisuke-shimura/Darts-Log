class User < ApplicationRecord
  enum gender: { undefined: 0, male: 1, female: 2, other: 3 }
end
