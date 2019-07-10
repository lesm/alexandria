require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  let(:key) { create :api_key }

  it 'is valid on creation' do
    expect(key).to be_valid
  end

  describe '#disable' do
    it 'disables the key' do
      key.disable
      expect(key.reload).to_not be_active
    end
  end
end
