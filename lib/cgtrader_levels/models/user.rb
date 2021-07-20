class CgtraderLevels::User < ActiveRecord::Base
  attr_reader :level

  after_initialize do
    self.reputation = 0

    if matching_level
      self.level_id = matching_level.id
      @level = matching_level
    end
  end

  after_update :set_new_level

  private

  def matching_level
    CgtraderLevels::Level
      .where("experience <= ?", reputation)
      .order('experience DESC')
      .first
  end

  def set_new_level
    if matching_level
      self.level_id = matching_level.id
      @level = matching_level
    end
  end
end
