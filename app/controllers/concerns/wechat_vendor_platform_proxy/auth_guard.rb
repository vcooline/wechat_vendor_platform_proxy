module WechatVendorPlatformProxy
  module AuthGuard
    extend ActiveSupport::Concern
    InvalidAuthTypeError = Class.new(StandardError)
    InvalidAuthValueError = Class.new(StandardError)
    NotAllowedRemoteIpError = Class.new(StandardError)
    AuthenticateFailError = Class.new(StandardError)

    SupportedAuthTypes = ["PlainUserToken", "PlainClientToken"]
    UrlAuthTypeMappings = { auth_token: "PlainClientToken" }

    included do
      rescue_from AuthenticateFailError, with: :handle_auth_failure
      rescue_from NotAllowedRemoteIpError, with: :handle_remote_ip_not_allowed
    end

    module ClassMethods
    end

    private
      def authenticate
        raise AuthenticateFailError unless current_user.present? || params[:in_iframe]
      end

      def current_user
        @current_user ||= auth_params.present? ? authenticate_user : session_user
      end

      def session_user
        User.find_by(id: session[:user_id])
      end

      def authenticate_user
        send("authenticate_user_using_#{auth_params[:type].underscore}", auth_params[:value])&.tap { |u| session[:user_id] = u.id }
      end

      def authenticate_client
        send("authenticate_client_using_#{auth_params[:type].underscore}", auth_params[:value])
      rescue => e
        logger.error "#{e.class.name}: #{e.message}"
        raise AuthenticateFailError, "#{e.class.name}: #{e.message}"
      end

      def authenticate_user_using_plain_user_token(token_value)
        find_user_using_plain_user_token(token_value) || create_user_using_plain_user_token(token_value)
      end

      def authenticate_client_using_plain_client_token(token_value)
        raise InvalidAuthValueError unless token_value == ENVConfig.client_auth_token
      end

      def find_user_using_plain_user_token(token_value)
        User::Credential.find_by(token: token_value)&.user
      end

      def create_user_using_plain_user_token(token_value)
        User.transaction do
          User.create!(uid: SecureRandom.base58).tap{|u| u.credentials.create!(token: token_value) }
        end
      end

      def auth_params
        @auth_params ||= auth_params_from_header || auth_params_from_url
      end

      def auth_params_from_header
        if request.authorization.present?
          HashWithIndifferentAccess.new.tap{ |p| p[:type], p[:value] = request.authorization&.split }.tap do |p|
            raise(InvalidAuthTypeError, "auth type not supported.") if SupportedAuthTypes.exclude?(p[:type])
            raise(InvalidAuthValueError, "auth value is blank.") if p[:value].blank?
          end
        end
      end

      def auth_params_from_url
        UrlAuthTypeMappings.each do |original_type, type|
          return {type: type, value: params[original_type]} if params[original_type].present?
        end
        return nil
      end

      def check_remote_ip_whitelisted
        unless request.remote_ip.in?(ENVConfig.remote_ip_whitelist.to_s.split(","))
          logger.error "remote ip not in whitelist: #{request.remote_ip}"
          raise NotAllowedRemoteIpError, "remote ip not in whitelist: #{request.remote_ip}"
        end
      end

      def verify_params_sign(biz_params, timestamp, nonce, signature)
      end

      def handle_auth_failure
        respond_to do |format|
          format.html { render plain: "权限不足，请联系管理员。", status: :forbidden }
          format.json { render json: {error: {message: "Unauthenticated"}}, status: :forbidden }
        end
      end

      def handle_remote_ip_not_allowed
        respond_to do |format|
          format.html { render plain: "请确认访问客户端已加入IP白名单", status: :forbidden }
          format.json { render json: {error: {message: "Not in ip whitelist"}}, status: :forbidden }
        end
      end
  end
end
