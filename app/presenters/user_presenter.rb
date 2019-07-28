class UserPresenter < BasePresenter
  FIELDS = %i(id email given_name family_name role last_logged_in_at
              confirmed_at confirmation_sent_at reset_password_sent_at
              created_at updated_at)
  FIELDS_TO_BUILD = FIELDS + %i(confirmation_token reset_password_token
                                confirmation_redirect_url
                                reset_password_redirect_url)
  build_with *FIELDS_TO_BUILD
  #related_to
  sort_by *FIELDS
  filter_by *FIELDS
end
