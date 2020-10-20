class ArticlesController < ApplicationController
  def index
    articles = Article.recent.
      page(params[:page]).
      per(params[:per_page])
    render json: articles
  end

  def show
  end

  private

  def serializer
    ArticleSerializer
  end
end