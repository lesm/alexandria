class Author < ApplicationRecord
  include PgSearch
  multisearchable against: [:given_name, :family_name]

  has_many :books

  validates :given_name, :family_name, presence: true
end
