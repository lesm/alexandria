class BooksController < ApplicationController
  def index
    books = orchestrate_query(Book.all).map do |book|
      BookPresenter.new(book, params).fields.embeds
    end
    render json: { data: books }
  end
end
