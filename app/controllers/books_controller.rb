class BooksController < ApplicationController
  def index
    books = orchestrate_query(Book.all)
    render serializer(books)
  end
end
