require 'rails_helper'

RSpec.describe BookPresenter, type: :presenter do
  let(:attributes) do
    %w(id title subtitle isbn_10 isbn_13 description
      released_on publisher_id author_id created_at
      updated_at cover)
  end

  describe '.build_attributes' do
    it 'returns the fields which are used to build' do
      expect(BookPresenter.build_attributes).to eq attributes
    end
  end
end
