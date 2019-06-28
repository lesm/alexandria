require 'rails_helper'

RSpec.describe EagerLoader do
  let(:books) { create_list :book, 3 }
  let(:params) { { embed: 'author', include: 'author' } }
  let(:scope) { Book.all }
  let(:eager_loader) { EagerLoader.new(scope, params) }
  let(:loaded) { eager_loader.load }

  before :each do
    allow(BookPresenter).to(
      receive(:relations).and_return(['author'])
    )
    books
  end

  xdescribe '#load' do
    context 'withuot params' do
      it 'returns the scope unchanged' do
        expect(loaded).to eq scope
      end
    end

    context 'with valid params' do
      it 'returns the scope unchanged' do
        expect(loaded.first.association(:author)).to eq be_loaded
      end
    end
  end
end
