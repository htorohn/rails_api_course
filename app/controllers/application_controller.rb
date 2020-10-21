class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error

  def render(options = {})
    paginator = JSOM::Pagination::Paginator.new

    if params[:page].present?
      paginated = paginator.call(options[:json], params: { number: params[:page][:number], size: params[:page][:size] }, base_url: request.url)
    else
      paginated = paginator.call(options[:json], params: { number: 1, size: 25 }, base_url: request.url)
    end
    options = { meta: paginated.meta.to_h, links: paginated.links.to_h }
    options[:json] = serializer.new(paginated.items, options)

    super(options)
  end

  private

  def authentication_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" => "Authentication code is invalid",
      "detail" => "You must provide valid code in order to exchange it for token.",
    }
    render json: { "errors": [error] }, status: 401
  end
end
