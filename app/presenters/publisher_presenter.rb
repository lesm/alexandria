class PublisherPresenter < BasePresenter
  build_with :id, :name, :created_at, :updated_at
  related_to :books
  sort_by :id, :name, :created_at, :updated_at
  filter_by :id, :name, :created_at, :updated_at
end
