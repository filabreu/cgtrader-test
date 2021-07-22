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
    let!(:coins_reward_1) { CgtraderLevels::Reward.create!(level: level_2, target: 'coins', amount: 7) }
    let!(:tax_reward_1) { CgtraderLevels::Reward.create!(level: level_2, target: 'tax', amount: -1) }
    let!(:coins_reward_2) { CgtraderLevels::Reward.create!(level: level_3, target: 'coins', amount: 10) }
    let!(:tax_reward_2) { CgtraderLevels::Reward.create!(level: level_3, target: 'tax', amount: -1) }

    context '1 level up' do
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
    end

    context '2 levels up' do
      it 'gives 17 coins to user' do
        expect {
          user.update_attribute(:reputation, 15)
        }.to change { user.reload.coins }.from(1).to(18)
      end

      it 'reduces tax rate by 2' do
        expect {
          user.update_attribute(:reputation, 15)
        }.to change { user.reload.tax }.from(30).to(28)
      end
    end

    context '1 level down' do
      let(:user) { CgtraderLevels::User.create!(coins: 18, tax: 28, reputation: 15) }

      it 'reduces 10 coins to user' do
        expect {
          user.update_attribute(:reputation, 10)
        }.to change { user.reload.coins }.from(18).to(8)
      end

      it 'increases tax rate by 1' do
        expect {
          user.update_attribute(:reputation, 10)
        }.to change { user.reload.tax }.from(28).to(29)
      end
    end

    context '2 levels down' do
      let(:user) { CgtraderLevels::User.create!(coins: 18, tax: 28, reputation: 15) }

      it 'reduces 18 coins to user' do
        expect {
          user.update_attribute(:reputation, 0)
        }.to change { user.reload.coins }.from(18).to(1)
      end

      it 'increases tax rate by 2' do
        expect {
          user.update_attribute(:reputation, 0)
        }.to change { user.reload.tax }.from(28).to(30)
      end
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
