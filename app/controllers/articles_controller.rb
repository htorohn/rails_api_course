class ArticlesController < ApplicationController
  def index
    articles = Article.recent
    render_collection articles
  end

  def show
    render_single json: Article.find(params[:id])
  end

  private

  def serializer
    ArticleSerializer
  end
end
