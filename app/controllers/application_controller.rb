class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end

  include JsonapiErrorsHandler

  # ErrorMapper.map_errors!({
  #   "ActiveRecord::RecordNotFound" => "JsonapiErrorsHandler::Errors::NotFound",
  #   "ActiveRecord::ActiveRecord::RecordInvalid" => "JsonapiErrorsHandler::Errors::Invalid",
  # })
  rescue_from ::StandardError, with: lambda { |e| handle_error(e) }
  rescue_from UserAuthenticator::AuthenticationError, with: lambda { |e| handle_error(e) }
  rescue_from AuthorizationError, with: lambda { |e| handle_error(e) }
  rescue_from ActiveRecord::RecordInvalid, with: lambda { |e| handle_validation_error(e) }

  def handle_validation_error(error)
    pp error
    error_model = error.try(:model) || error.try(:record)
    mapped = JsonapiErrorsHandler::Errors::Invalid.new(errors: error_model.errors)
    render_error(mapped)
  end

  # rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error
  # rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  def render_single(options = {})
    render json: serializer.new(options[:json]), status: options[:status]
  end

  def render_collection(collection)
    if params[:page].present?
      paginated = paginator.call(collection, params: { number: params[:page][:number], size: params[:page][:size] }, base_url: request.url)
    else
      paginated = paginator.call(collection, params: params[:page], base_url: request.url)
    end
    options = {
      meta: paginated.meta.to_h,
      links: paginated.links.to_h,
    }

    render json: serializer.new(paginated.items, options)
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

  def authentication_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" => "Authentication code is invalid",
      "detail" => "You must provide valid code in order to exchange it for token.",
    }
    render json: { "errors": [error] }, status: 401
  end

  def authorization_error
    error = {
      "status" => "403",
      "source" => { "pointer" => "/headers/authorization" },
      "title" => "Not authorized",
      "detail" => "You have no right to access this resource.",
    }
    render json: { "errors": [error] }, status: 403
  end
end
