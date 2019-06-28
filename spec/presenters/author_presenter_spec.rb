require 'rails_helper'

RSpec.describe AuthorPresenter do
  let(:build_attributes) do
    %w(id given_name family_name created_at updated_at)
  end
  let(:relations) { %w(books)  }
  let(:sort_attributes) do
    %w(id given_name family_name created_at updated_at)
  end
  let(:filter_attributes) do
    %w(id given_name family_name created_at updated_at)
  end

  describe '.build_attributes' do
    it 'returns the fields which are used to build' do
      expect(AuthorPresenter.build_attributes).to eq build_attributes
    end
  end

  describe '.relations' do
    it 'returns the fields which are used to build' do
      expect(AuthorPresenter.relations).to eq relations
    end
  end

  describe '.sort_attributes' do
    it 'returns the fields which are used to build' do
      expect(AuthorPresenter.sort_attributes).to eq sort_attributes
    end
  end

  describe '.filter_attributes' do
    it 'returns the fields which are used to build' do
      expect(AuthorPresenter.filter_attributes).to eq filter_attributes
    end
  end
end
