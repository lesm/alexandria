class UsersController < ApplicationController
  before_action :authenticate_user, only: [:index, :show, :update, :destroy]

  def index
    @users = orchestrate_query(User.all)
    render serializer @users
  end

  def show
    render serializer user
  end

  def create
    if user.save
      UserMailer.confirmation_email(user).deliver_now
      render serializer(user).merge(status: :created, location: user)
    else
      unprocessable_entity! user
    end
  end

  def update
    if user.update(user_params)
      render serializer(user).merge(status: :ok)
    else
      unprocessable_entity! user
    end
  end

  def destroy
    user.destroy
    render status: :no_content
  end

  private

  def user
    @user ||= params[:id] ? User.find_by!(id: params[:id]) : User.new(user_params)
  end
  alias_method :resource, :user

  def user_params
    params.require(:data).permit(:email, :password,
                                 :given_name, :family_name,
                                 :role, :confirmation_redirect_url)
  end
end
