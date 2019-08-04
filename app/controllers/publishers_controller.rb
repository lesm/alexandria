class PublishersController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :destroy]

  def index
    publishers = orchestrate_query(Publisher.all)
    render serializer(publishers)
  end

  def show
    render serializer(publisher)
  end

  def create
    if publisher.save
      render serializer(publisher).merge(status: :created, location: publisher)
    else
      unprocessable_entity!(publisher)
    end
  end

  def update
    if publisher.update(publisher_params)
      render serializer(publisher).merge(status: :ok)
    else
      unprocessable_entity!(publisher)
    end
  end

  def destroy
    publisher.destroy
    render status: :no_content
  end

  private

  def publisher
    @publisher ||= params[:id] ? Publisher.find_by!(id: params[:id]) : Publisher.new(publisher_params)
  end
  alias_method :resource, :publisher

  def publisher_params
    params.require(:data).permit(:name)
  end
end
