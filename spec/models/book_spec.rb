require 'rails_helper'

RSpec.describe Book, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :released_on }
  it { should validate_presence_of :author }
  it { should validate_presence_of :isbn_10 }
  it { should validate_presence_of :isbn_13 }
  it { should validate_length_of(:isbn_10).is_equal_to(10) }
  it { should validate_length_of(:isbn_13).is_equal_to(13) }
  #it { should belong_to(:publisher) } waiting support for optional
  it { should belong_to :author }

  describe 'uniqueness' do
    context 'isbn_10' do
      subject { build :book, isbn_10: '1234567890' }
      it {  should validate_uniqueness_of(:isbn_10).case_insensitive }
    end

    context 'isbn_13' do
      subject { build :book, isbn_13: '1234567890123' }
      it {  should validate_uniqueness_of(:isbn_13).case_insensitive }
    end
  end

  it 'has a valid factory' do
    expect(build :book).to be_valid
  end
end
