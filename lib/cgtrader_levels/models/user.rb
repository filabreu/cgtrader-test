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
      new_attributes = {
        'coins' => coins,
        'tax' => tax
      }

      levels_evolved.map(&:rewards).flatten.each do |reward|
        new_attributes[reward.target] += reward.amount
      end

      assign_attributes(new_attributes)
    end
  end

  def levels_evolved
    CgtraderLevels::Level
      .where("experience > ? AND experience <= ?",
        changes['reputation'][0],
        changes['reputation'][1]
      )
  end
end
