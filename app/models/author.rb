class Author < ApplicationRecord
  validates :given_name, :family_name, presence: true
end
