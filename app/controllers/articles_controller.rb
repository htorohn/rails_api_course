class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  def index
    render_collection json: Article.recent
  end

  def show
    render_single json: Article.find(params[:id])
  end

  def create
    @article = Article.create!(article_params)
    render_single json: @article, status: :created
  end

  def update
    article = Article.find(params[:id])
    article.update_attributes!(article_params)
    render_single json: article, status: :ok
  end

  private

  def article_params
    params.require(:data).require(:attributes).
      permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end

  def serializer
    ArticleSerializer
  end
end
