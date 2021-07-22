class CgtraderLevels::Level < ActiveRecord::Base
  has_many :rewards
  has_many :users
end
