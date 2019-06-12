class Author < ApplicationRecord
  has_many :books

  validates :given_name, :family_name, presence: true
end
