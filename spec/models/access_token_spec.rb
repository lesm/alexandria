require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:access_token) { create :access_token }

  it 'has a valid factory' do
    expect(access_token).to be_valid
  end

  it { should belong_to :user }
  it { should belong_to :api_key }

  describe '#authenticate' do
    context 'when valid' do
      it 'authenticates' do
        token = access_token.generate_token
        expect(access_token.authenticate(token)).to be true
      end
    end

    context 'when invalid' do
      it 'fails to authenticate' do
        access_token.generate_token
        expect(access_token.authenticate('fake')).to be false
      end
    end
  end

  describe '#expired?' do
    context 'when expired' do
      it 'returns true' do
        access_token.update_column(:created_at, 15.days.ago)
        expect(access_token).to be_expired
      end
    end

    context 'when not expired' do
      it 'returns false' do
        access_token.update_column(:created_at, 10.days.ago)
        expect(access_token).to_not be_expired
      end
    end
  end

  describe '#generate_token' do
    it 'generates an access token digest' do
      access_token.generate_token
      expect(access_token.token_digest).to_not be_nil
    end

    it 'returns an access token' do
      token = access_token.generate_token
      expect(token).to_not be_nil
    end
  end
end
