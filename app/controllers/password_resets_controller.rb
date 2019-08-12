class PasswordResetsController < ApplicationController
  skip_before_action :validate_auth_scheme, only: :show
  skip_before_action :authenticate_client, only: :show
  before_action :skip_authorization

  def show
    reset = PasswordReset.new(reset_token: params[:reset_token])
    redirect_to reset.redirect_url
  end

  def create
    handle_password_reset(:create) do
      UserMailer.reset_password(reset.user).deliver_now
      render status: :no_content, location: reset.user
    end
  end

  def update
    reset.reset_token = params[:reset_token]
    handle_password_reset(:update) do
      render status: :no_content
    end
  end

  private

  def handle_password_reset method
    if reset.send(method)
      yield if block_given?
    else
      unprocessable_entity! reset
    end
  end

  def reset
    @reset ||= PasswordReset.new(reset_params)
  end

  def reset_params
    params.require(:data).permit(
      :email, :reset_password_redirect_url, :password
    )
  end
end
