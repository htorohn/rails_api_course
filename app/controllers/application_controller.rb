class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end

  #siempre valida que sea un request autentico
  before_action :authorize!
  ##------------

  include JsonapiErrorsHandler

  ErrorMapper.map_errors!({
    "ActiveRecord::RecordNotFound" => "JsonapiErrorsHandler::Errors::NotFound",
    "ActiveRecord::ActiveRecord::RecordInvalid" => "JsonapiErrorsHandler::Errors::Invalid",
    "ApplicationController::AuthorizationError" => "JsonapiErrorsHandler::Errors::Forbidden",
    "UserAuthenticator::AuthenticationError" => "JsonapiErrorsHandler::Errors::Unauthorized",
  })
  rescue_from ::StandardError, with: lambda { |e| handle_error(e) }
  rescue_from ActiveRecord::RecordInvalid, with: lambda { |e| handle_validation_error(e) }

  def handle_validation_error(error)
    error_model = error.try(:model) || error.try(:record)
    mapped = JsonapiErrorsHandler::Errors::Invalid.new(errors: error_model.errors)
    render_error(mapped)
  end

  def render_single(options = {})
    render json: serializer.new(options[:json]), status: options[:status]
  end

  def render_collection(options = {})
    if params[:page].present?
      paginated = paginator.call(options[:json], params: { number: params[:page][:number], size: params[:page][:size] }, base_url: request.url)
    else
      paginated = paginator.call(options[:json], params: params[:page], base_url: request.url)
    end
    serializer_options = {
      meta: paginated.meta.to_h,
      links: paginated.links.to_h,
    }

    render json: serializer.new(paginated.items, serializer_options), status: options[:status]
  end

  private

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, "")
    # the & operator reutrns null instead of raise error when the object is null
    # the regex replace the string Bearer\s for empty string to leave just de token
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def paginator
    JSOM::Pagination::Paginator.new
  end
end
