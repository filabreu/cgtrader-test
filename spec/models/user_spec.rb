require 'spec_helper'

describe CgtraderLevels::User do
  describe 'new user' do
    it 'has 0 reputation points' do
      @user = CgtraderLevels::User.new
      expect(@user.reputation).to eq(0)
    end

    it "has assigned 'First level'" do
      @level = CgtraderLevels::Level.create!(experience: 0, title: 'First level')
      @user = CgtraderLevels::User.new

      expect(@user.level).to eq(@level)
    end
  end

  describe 'level up' do
    it "level ups from 'First level' to 'Second level'" do
      @level_1 = CgtraderLevels::Level.create!(experience: 0, title: 'First level')
      @level_2 = CgtraderLevels::Level.create!(experience: 10, title: 'Second level')
      @user = CgtraderLevels::User.create!

      expect {
        @user.update_attribute(:reputation, 10)
      }.to change { @user.reload.level }.from(@level_1).to(@level_2)
    end

    it "level ups from 'First level' to 'Second level'" do
      @level_1 = CgtraderLevels::Level.create!(experience: 0, title: 'First level')
      @level_2 = CgtraderLevels::Level.create!(experience: 10, title: 'Second level')
      @level_3 = CgtraderLevels::Level.create!(experience: 13, title: 'Third level')
      @user = CgtraderLevels::User.create!

      expect {
        @user.update_attribute(:reputation, 11)
      }.to change { @user.reload.level }.from(@level_1).to(@level_2)
    end
  end

  describe 'level up bonuses & privileges' do
    it 'gives 7 coins to user' do
      @level_1 = CgtraderLevels::Level.create!(experience: 0, title: 'First level')
      @level_2 = CgtraderLevels::Level.create!(experience: 10, title: 'Second level')
      @reward_1 = CgtraderLevels::Reward.create!(level: @level_1, type: 'CgtraderLevels::Coin', amount: 1)
      @reward_2 = CgtraderLevels::Reward.create!(level: @level_2, type: 'CgtraderLevels::Coin', amount: 8)

      @user = CgtraderLevels::User.create!

      expect {
        @user.update_attribute(:reputation, 10)
      }.to change { @user.reload.coins }.from(1).to(8)
    end

    it 'reduces tax rate by 1' do
      @level_1 = CgtraderLevels::Level.create!(experience: 0, title: 'First level')
      @level_2 = CgtraderLevels::Level.create!(experience: 10, title: 'Second level')
      @reward_1 = CgtraderLevels::Reward.create!(level: @level_1, type: 'CgtraderLevels::TaxRate', amount: 20)
      @reward_2 = CgtraderLevels::Reward.create!(level: @level_2, type: 'CgtraderLevels::TaxRate', amount: 19)
      @user = CgtraderLevels::User.create!

      expect {
        @user.update_attribute(:reputation, 10)
      }.to change { @user.reload.tax_rate }.from(20).to(19)
    end
  end
end
