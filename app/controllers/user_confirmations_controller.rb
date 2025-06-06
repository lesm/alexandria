class UserConfirmationsController < ApplicationController
  before_action :confirmation_token_not_found
  before_action :skip_authorization

  def show
    user.confirm

    if user.confirmation_redirect_url
      redirect_to user.confirmation_redirect_url
    else
      render plain: 'You are now confirmed!'
    end
  end

  private

  def confirmation_token_not_found
    render(status: 404, plain: "Token not found") if user.blank?
  end

  def confirmation_token
    @confirmation_token || params[:confirmation_token]
  end

  def user
    @user ||= User.where(confirmation_token: confirmation_token).first
  end
end
