require 'rails_helper'

RSpec.describe EmbedPicker do
  let(:author) { create :author }
  let(:book_1) { create :book, author: author }
  let(:book_2) { create :book, author: author }

  let(:params) { {} }
  let(:embed_picker) { EmbedPicker.new(presenter) }

  describe '#embed' do
    context 'with book (many to one) as the resource' do
      let(:presenter) { BookPresenter.new(book_1, params)  }

      before :each do
        allow(BookPresenter).to(
          receive(:relations).and_return(['author'])
        )
      end

      context "with no 'embed' parameter" do
        it "returns the 'data' hash without changing it" do
          expect(embed_picker.embed.data).to eq presenter.data
        end
      end

      context "with invalid relation 'something'" do
        let(:params) { { embed: 'something' } }

        it "raises a 'RepresentationBuilderError'" do
          expect { embed_picker.embed }.to(
            raise_error(RepresentationBuilderError))
        end
      end

      context "with the 'embed' parameter containing 'author'" do
        let(:params) { { embed: 'author' } }

        it "embeds the 'author' data" do
          expect(embed_picker.embed.data[:author]).to eq({
            'id'          => book_1.author.id,
            'given_name'  => book_1.author.given_name,
            'family_name' => book_1.author.family_name,
            'created_at'  => book_1.author.created_at,
            'updated_at'  => book_1.author.updated_at,
          })
        end
      end

      context "with the 'embed' parameter containing 'books'" do
        let(:params) { { embed: 'books' } }
        let(:presenter) { AuthorPresenter.new(author, params) }

        before :each do
          book_1 && book_2
          allow(AuthorPresenter).to(
            receive(:relations).and_return(['books'])
          )
        end

        it "embeds the 'books' data" do
          expect(embed_picker.embed.data[:books].size).to eq 2
          expect(embed_picker.embed.data[:books].first['id']).to eq book_1.id
          expect(embed_picker.embed.data[:books].last['id']).to eq book_2.id
        end
      end
    end
  end
end
