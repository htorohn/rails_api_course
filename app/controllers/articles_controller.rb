class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  def index
    articles = Article.recent
    render_collection articles
  end

  def show
    render_single json: Article.find(params[:id])
  end

  def create
    article = Article.new(article_params)
    if article.valid?
      #we will figure that out
    else
      render json: article, adapter: :json_api,
        serializer: ErrorSerializer,
        status: :unprocessable_entity
    end
  end

  private

  def article_params
    ActionController::Parameters.new
  end

  def serializer
    ArticleSerializer
  end
end
