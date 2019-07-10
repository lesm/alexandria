module Authentication
  extend ActiveSupport::Concern

  AUTH_SCHEME = 'Alexandria-Token'

  included do
    before_action :validate_auth_scheme
    before_action :authenticate_client
  end

  protected

  def authenticate_client
    unauthorized!('Client Realm') unless api_key
  end

  def validate_auth_scheme
    unless authorization_request.match(/^#{AUTH_SCHEME}/)
      unauthorized!('Client Realm')
    end
  end

  private

  def unauthorized!(realm)
    headers["WWW-Authenticate"] = %(#{AUTH_SCHEME} realm="#{realm}")
    render status: 401
  end

  def authorization_request
    @authorization_request ||= request.authorization.to_s
  end

  def api_key
    return nil if credentials['api_key'].blank?
    @api_key ||= ApiKey.activated.where(key: credentials['api_key']).first
  end

  def credentials
    @credentials ||= Hash[authorization_request.scan(/(\w+)[:=](\w+)/)]
  end
end
