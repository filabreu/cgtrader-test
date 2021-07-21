class CgtraderLevels::User < ActiveRecord::Base
  belongs_to :level

  after_initialize :set_starting_reputation, if: :new_record?
  after_initialize :set_new_level, if: :new_record?

  before_update :set_new_level
  before_update :apply_rewards

  private

  def matching_level
    CgtraderLevels::Level
      .where("experience <= ?", reputation)
      .order('experience DESC')
      .first
  end

  def set_starting_reputation
    self.reputation = 0
  end

  def set_new_level
    if matching_level
      self.level_id = matching_level.id
    end
  end

  def apply_rewards
    if level_id_changed?
      new_attributes = {}

      level.rewards.each do |reward|
        new_attributes[reward.target] = send(reward.target) + reward.amount
      end

      assign_attributes(new_attributes)
    end
  end
end
