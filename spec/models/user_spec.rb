require 'spec_helper'

describe CgtraderLevels::User do
  let(:user) { CgtraderLevels::User.create! }
  let!(:level_1) { CgtraderLevels::Level.create!(experience: 0, title: 'First level') }
  let!(:level_2) { CgtraderLevels::Level.create!(experience: 10, title: 'Second level') }
  let!(:level_3) { CgtraderLevels::Level.create!(experience: 13, title: 'Third level') }

  context 'new user' do
    let(:user) { CgtraderLevels::User.new }

    describe '#reputation' do
      subject { user.reputation }
      
      it { is_expected.to eq 0 }
    end

    describe '#level' do
      subject { user.level }
      
      it { is_expected.to eq level_1 }
    end
  end

  describe '#level' do
    it "level ups from 'First level' to 'Second level'" do
      expect {
        user.update_attribute(:reputation, 10)
      }.to change { user.reload.level }.from(level_1).to(level_2)
    end

    it "level ups from 'First level' to 'Second level'" do
      expect {
        user.update_attribute(:reputation, 11)
      }.to change { user.reload.level }.from(level_1).to(level_2)
    end
  end

  describe '#apply_rewards' do
    let(:user) { CgtraderLevels::User.create!(coins: 1) }
    let!(:coins_reward) { CgtraderLevels::Reward.create!(level: level_2, target: 'coins', amount: 7) }
    let!(:tax_reward) { CgtraderLevels::Reward.create!(level: level_2, target: 'tax', amount: -1) }

    it 'gives 7 coins to user' do
      expect {
        user.update_attribute(:reputation, 10)
      }.to change { user.reload.coins }.from(1).to(8)
    end

    it 'reduces tax rate by 1' do
      expect {
        user.update_attribute(:reputation, 10)
      }.to change { user.reload.tax }.from(30).to(29)
    end

    context 'when not leveling up' do
      it 'keeps coins' do  
        expect {
          user.update_attribute(:reputation, 9)
        }.not_to change { user.reload.coins }
      end
  
      it 'keeps tax rate' do  
        expect {
          user.update_attribute(:reputation, 9)
        }.not_to change { user.reload.tax }
      end
    end
  end
end
