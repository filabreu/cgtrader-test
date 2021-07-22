class CgtraderLevels::Reward < ActiveRecord::Base
  belongs_to :level

  validates :target, presence: true
  validates :amount, presence: true
end
