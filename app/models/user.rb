class User < ApplicationRecord
  enum gender: { other: 0, male: 1, female: 2 }
end
