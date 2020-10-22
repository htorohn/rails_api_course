class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error

  def render_single(options = {})
    render json: serializer.new(options[:json])
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
end
