class CgtraderLevels::User < ActiveRecord::Base
  belongs_to :level

  after_initialize :set_starting_reputation, if: :new_record?
  after_initialize :set_new_level, if: :new_record?

  before_update :set_new_level

  def tax_rate
    level.rewards.where(type: 'CgtraderLevels::TaxRate').first.amount
  end

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
end
