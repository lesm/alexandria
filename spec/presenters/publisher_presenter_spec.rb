require 'rails_helper'

RSpec.describe PublisherPresenter do
  let(:build_attributes) do
    %w(id name created_at updated_at)
  end
  let(:relations) { %w(books)  }
  let(:sort_attributes) do
    %w(id name created_at updated_at)
  end
  let(:filter_attributes) do
    %w(id name created_at updated_at)
  end

  describe '.build_attributes' do
    it 'returns the fields which are used to build' do
      expect(PublisherPresenter.build_attributes).to eq build_attributes
    end
  end

  describe '.relations' do
    it 'returns the fields which are used to build' do
      expect(PublisherPresenter.relations).to eq relations
    end
  end

  describe '.sort_attributes' do
    it 'returns the fields which are used to build' do
      expect(PublisherPresenter.sort_attributes).to eq sort_attributes
    end
  end

  describe '.filter_attributes' do
    it 'returns the fields which are used to build' do
      expect(PublisherPresenter.filter_attributes).to eq filter_attributes
    end
  end
end
