require 'rails_helper'

RSpec.describe BookPolicy do
  subject { described_class }

  permissions :index?, :show? do
    it 'grants access' do
      expect(subject).to permit(nil, Book.new)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access if user is not admin' do
      expect(subject).not_to permit(build(:user), Book.new)
    end

    it 'granst access if user is admin' do
      expect(subject).to permit(build(:admin), Book.new)
    end
  end
end
