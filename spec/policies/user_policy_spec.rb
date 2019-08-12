require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  permissions :index? do
    it 'grants access if user is admin' do
      expect(subject).to permit(build(:admin), User.new)
    end
    it 'denies access if user is not admin' do
      expect(subject).to_not permit(build(:user), User.new)
    end
  end

  permissions :create? do
    it 'grants access' do
      expect(subject).to permit(nil, User.new)
    end
  end

  permissions :show?, :update?, :destroy? do
    let(:user) { create :user }
    it 'grants access if user is equals to the record' do
      expect(subject).to permit(user, user)
    end

    it 'grants access if user admin' do
      expect(subject).to permit(build(:admin), user)
    end

    it 'denies access if user is not equals to the record' do
      expect(subject).to_not permit(build(:user), user)
    end
  end
end


