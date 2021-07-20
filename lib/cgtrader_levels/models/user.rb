class CgtraderLevels::User < ActiveRecord::Base
  attr_reader :level, :tax_rate

  after_initialize do
    self.reputation = 0

    if matching_level
      self.level_id = matching_level.id
      @level = matching_level
    end

    if matching_tax_rate
      @tax_rate = matching_tax_rate.amount
    end
  end

  after_update :set_new_level

  def matching_tax_rate
    @level.rewards.where(type: 'CgtraderLevels::TaxRate').first
  end

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
