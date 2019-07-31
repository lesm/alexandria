class PasswordReset
  include ActiveModel::Model

  attr_accessor :email, :reset_password_redirect_url

  validates :email, :reset_password_redirect_url, presence: true

  def create
    user && valid? && user.init_password_reset(reset_password_redirect_url)
  end

  def user
    @user ||= retrieve_user
  end

  private

  def retrieve_user
    user = User.where(email: email).first
    raise ActiveRecord::RecordNotFound unless user
    user
  end
end
