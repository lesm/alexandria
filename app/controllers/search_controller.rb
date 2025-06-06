class SearchController < ApplicationController
  before_action :skip_authorization

  def index
    @text = params[:text]
    scope = PgSearch.multisearch(@text).includes(:searchable)
    documents = orchestrate_query(scope)
    render serializer(documents).merge(status: :ok)
  end
end
