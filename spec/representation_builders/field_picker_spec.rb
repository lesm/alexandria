require 'rails_helper'

RSpec.describe FieldPicker do
  let(:book) { create :book }
  let(:params) { { fields: 'id,title' } }
  let(:presenter) { BookPresenter.new(book, params) }
  let(:field_picker) { FieldPicker.new(presenter) }

  before :each do
    allow(BookPresenter).to receive(:build_attributes).and_return(
      ['id','title','author_id']
    )
  end

  describe '#pick' do
    context "with the 'fields' parameter containing 'id,title'" do
      it "updates the presenter 'data' with the book 'id' and 'title'" do
        expect(field_picker.pick.data).to eq({
          'id'        => book.id,
          'title'     => book.title
        })
      end
    end

    context 'with overriding method defined in presenter' do
      before :each do
        presenter.class.send(:define_method, :title) { 'Overriden!' }
      end

      it "updates the presenter 'data' with the title 'Overriden!'" do
        expect(field_picker.pick.data).to eq({
          'id'    => book.id,
          'title' => 'Overriden!'
        })
      end

      after :each do
        presenter.class.send(:remove_method, :title)
      end
    end

    context "with no 'fields' parameters" do
      let(:params) { {} }
      it "updates 'data' with the fields ('id','title','author_id')" do
        expect(field_picker.pick.data).to eq({
          'id'        => book.id,
          'title'     => book.title,
          'author_id' => book.author.id
        })
      end
    end

    context "with invalid attributes 'fid'" do
      let(:params) { { fields: 'fid,title' } }

      it "raises a 'RepresentationBuilderError'" do
        expect { field_picker.pick }.to(
          raise_error(RepresentationBuilderError))
      end
    end
  end
end
