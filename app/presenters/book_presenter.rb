class BookPresenter < BasePresenter
  build_with :id, :title, :subtitle, :isbn_10, :isbn_13,
    :description, :released_on, :publisher_id, :author_id,
    :created_at, :updated_at, :cover
  related_to :publisher, :author
  sort_by :id, :title, :released_on, :created_at, :updated_at
  filter_by :id, :title, :isbn_10, :isbn_13, :released_on,
    :publisher_id, :author_id

  def cover
    path = super.url
    path[0] = '' if path[0] == '/'
    "#{root_url}#{path}"
  end
end
