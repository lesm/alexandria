require 'rails_helper'

RSpec.describe Sorter do
  let(:books) { create_list :book, 3 }
  let(:scope) { Book.all }
  let(:params) do
    HashWithIndifferentAccess.new(sort: 'id', dir: 'desc')
  end
  let(:sorter) { Sorter.new(scope, params) }
  let(:sorted) { sorter.sort }

  before do
    allow(BookPresenter).to(
      receive(:sort_attributes).and_return(['id','title'])
    )
    books
  end

  describe '#sort' do
    context 'without any parameters' do
      let(:params) { {} }
      it 'returns the scope unchanged' do
        expect(sorted).to eq scope
      end
    end

    context 'with valid parameters' do
      context 'by id desc' do
        it 'sorts the collection by "id desc"' do
          expect(sorted.first.id).to eq books.last.id
          expect(sorted.last.id).to eq books.first.id
        end
      end

      context 'by id asc' do
        let(:params) { { sort: 'id', dir: 'asc'} }
        it 'sorts the collections by "id asc"' do
          expect(sorted.first.id).to eq books.first.id
          expect(sorted.last.id).to eq books.last.id
        end
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        HashWithIndifferentAccess.new(sort: 'fid', dir: 'desc')
      end

      it 'raises a QueryBuilderError exception' do
        expect { sorted }.to raise_error(QueryBuilderError)
      end
    end
  end
end
