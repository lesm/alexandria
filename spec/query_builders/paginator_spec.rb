require 'rails_helper'

RSpec.describe Paginator do
  let(:book_1) { create :book }
  let(:book_2) { create :book }
  let(:book_3) { create :book }
  let(:books) { [book_1, book_2, book_3] }
  let(:scope) { Book.all }
  let(:params) { { 'page' => '1', 'per' => '2' } }
  let(:paginator) { Paginator.new(scope, params, 'url') }
  let(:paginated) { paginator.paginate }

  before { books }

  describe '#paginate' do
    it 'paginate the collections with 2 books' do
      expect(paginated.size).to eq 2
    end

    it 'contains book_1 as the first paginated item' do
      expect(paginated.first).to eq book_1
    end

    it 'contains book_3 as the last paginated item' do
      expect(paginated.last).to eq book_2
    end
  end

  describe '#links' do
    let(:links) { paginator.links.split(', ') }

    context 'when first page' do
      let(:params) { { 'page' => '1', 'per' => '2' } }

      it "builds the 'next' relation link" do
        expect(links.first).to eq '<url?page=2&per=2>; rel="next"'
      end

      it "builds the 'last' relation link" do
        expect(links.last).to eq '<url?page=2&per=2>; rel="last"'
      end
    end

    context 'when last page' do
      let(:params) { { 'page' => '2', 'per' => '2' } }

      it "builds the 'first' relation link" do
        expect(links.first).to eq '<url?page=1&per=2>; rel="first"'
      end

      it "builds the 'previous relation link'" do
        expect(links.last).to eq '<url?page=1&per=2>; rel="prev"'
      end
    end
  end
end
