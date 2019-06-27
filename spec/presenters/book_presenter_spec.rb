require 'rails_helper'

RSpec.describe BookPresenter, type: :presenter do
  let(:build_attributes) do
    %w(id title subtitle isbn_10 isbn_13 description
      released_on publisher_id author_id created_at
      updated_at cover)
  end
  let(:relations) { %w(publisher author)  }
  let(:sort_attributes) do
    %w(id title released_on created_at updated_at)
  end
  let(:filter_attributes) do
    %w(id title isbn_10 isbn_13 released_on publisher_id author_id)
  end

  describe '.build_attributes' do
    it 'returns the fields which are used to build' do
      expect(BookPresenter.build_attributes).to eq build_attributes
    end
  end

  describe '.relations' do
    it 'returns the fields which are used to build' do
      expect(BookPresenter.relations).to eq relations
    end
  end

  describe '.sort_attributes' do
    it 'returns the fields which are used to build' do
      expect(BookPresenter.sort_attributes).to eq sort_attributes
    end
  end

  describe '.filter_attributes' do
    it 'returns the fields which are used to build' do
      expect(BookPresenter.filter_attributes).to eq filter_attributes
    end
  end
end
