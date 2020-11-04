class ArticlesController < ApplicationController
  skip_before_action :authorize!, only: %i[index show]

  include JsonapiErrorsHandler

  def index
    render_collection json: Article.recent
  end

  def show
    render_single json: Article.find(params[:id])
  end

  def create
    @article = current_user.articles.build(article_params)
    @article.save!
    render_single json: @article, status: :created
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render_single json: article, status: :ok
  rescue ActiveRecord::RecordNotFound
    raise JsonapiErrorsHandler::Errors::Forbidden
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    raise JsonapiErrorsHandler::Errors::Forbidden
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
