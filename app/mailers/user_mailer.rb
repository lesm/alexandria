class UserMailer < ApplicationMailer

  def confirmation_email user
    @user = user
    @user.update_column(:confirmation_sent_at, Time.current)
    mail to: @user.email, subject: 'Confirm your Account!'
  end
end
