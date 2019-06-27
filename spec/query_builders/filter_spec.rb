require 'rails_helper'

RSpec.describe Filter do
  let(:book_1) do
    create :book,
      title: 'Ruby Under a Microscope',
      released_on: '2013-05-9'
  end
  let(:book_2) do
    create :book, title: 'Second book', released_on: '2014-09-9'
  end
  let(:book_3) do
    create :book, title: 'Third book', released_on: '2015-05-6'
  end
  let(:books) { [book_1, book_2, book_3] }

  let(:scope) { Book.all }
  let(:params) { {} }
  let(:filter) { Filter.new(scope, params) }
  let(:filtered) { filter.filter }

  before do
    allow(BookPresenter).to(
      receive(:filter_attributes).and_return(
        ['id','title','released_on'])
    )
    books
  end

  describe '#filter' do
    context 'without any parameters' do
      it 'returns the scope unchanged' do
        expect(filtered).to eq scope
      end
    end

    context 'with valid parameters' do
      context "with 'title_eq=Ruby Under a Microscope'" do
        let(:params) do
          { 'q' => { 'title_eq' => 'Ruby Under a Microscope' } }
        end

        it "gets only books where title is 'Ruby Under a Microscope'" do
          expect(filtered.first.id).to eq book_1.id
          expect(filtered.size).to eq 1
        end
      end

      context "with 'title_cont=Under'" do
        let(:params) do
          { 'q' => { 'title_cont' => 'Under' } }
        end

        it "gets only books where title content 'Under' word" do
          expect(filtered.first.id).to eq book_1.id
          expect(filtered.size).to eq 1
        end
      end

      context "with 'title_notcont=Ruby'" do
        let(:params) do
          { 'q' => { 'title_notcont' => 'Ruby' } }
        end

        it "gets only books where title doesn't have 'Ruby' word" do
          expect(filtered.first.id).to eq book_2.id
          expect(filtered.last.id).to eq book_3.id
          expect(filtered.size).to eq 2
        end
      end

      context "with 'title_start=Ruby'" do
        let(:params) do
          { 'q' => { 'title_start' => 'Ruby' } }
        end

        it "gets only books where title start with 'Ruby' word" do
          expect(filtered.size).to eq 1
        end
      end

      context "with 'title_end=book'" do
        let(:params) do
          { 'q' => { 'title_end' => 'book' } }
        end

        it "gets only books where title ends with 'book' word" do
          expect(filtered.size).to eq 2
        end
      end

      context "with 'released_on_lt=2013-05-10'" do
        let(:params) do
          { 'q' => { 'released_on_lt' => '2013-05-10' } }
        end

        it "gets only books with released_on before '2013-05-10'" do
          expect(filtered.first).to eq book_1
          expect(filtered.size).to eq 1
        end
      end

      context "with 'released_on_gt=2013-05-10'" do
        let(:params) do
          { 'q' => { 'released_on_gt' => '2013-05-10' } }
        end

        it "gets only books with released_on after '2013-05-10'" do
          expect(filtered.first).to eq book_2
          expect(filtered.last).to eq book_3
          expect(filtered.size).to eq 2
        end
      end
    end
  end
end
