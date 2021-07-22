class CgtraderLevels::User < ActiveRecord::Base
  belongs_to :level

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

  def matching_level?
    !!matching_level
  end

  def set_new_level
    if matching_level?
      self.level_id = matching_level.id
    end
  end

  def apply_rewards
    if level_id_changed?
      CgtraderLevels::Rewarder.new(self).apply
    end
  end
end
