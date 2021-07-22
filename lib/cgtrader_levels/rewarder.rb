module CgtraderLevels
  class Rewarder
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def apply
      if evolving? || regressing?
        new_attributes = {
          'coins' => user.coins,
          'tax' => user.tax
        }

        changed_levels.map(&:rewards).flatten.each do |reward|
          if evolving?
            new_attributes[reward.target] += reward.amount
          else
            new_attributes[reward.target] -= reward.amount
          end
        end

        user.assign_attributes(new_attributes)
      end
    end

    def evolving?
      current_reputation < final_reputation
    end

    def regressing?
      current_reputation > final_reputation
    end

    def current_reputation
      @current_reputation ||= user.changes['reputation'][0]
    end

    def final_reputation
      @final_reputation ||= user.changes['reputation'][1]
    end

    def levels_up
      CgtraderLevels::Level
        .where("experience > ? AND experience <= ?",
          current_reputation,
          final_reputation
        )
    end
  
    def levels_down
      CgtraderLevels::Level
        .where("experience > ? AND experience <= ?",
          final_reputation,
          current_reputation
        )
    end

    def changed_levels
      evolving? ? levels_up : levels_down
    end
  end
end
