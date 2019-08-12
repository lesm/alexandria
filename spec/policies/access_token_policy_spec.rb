require 'rails_helper'

RSpec.describe AccessTokenPolicy do
  subject { described_class }

  permissions :create? do
    it 'grants access' do
      expect(subject).to permit(nil, AccessToken.new)
    end
  end

  permissions :destroy? do
    let(:user) { create :user }
    it 'denies access if record does not belong to user' do
      expect(subject).not_to permit(build(:user), AccessToken.new)
    end

    it 'granst access if record belong to user' do
      expect(subject).to permit(user, user.access_tokens.build)
    end
  end
end


