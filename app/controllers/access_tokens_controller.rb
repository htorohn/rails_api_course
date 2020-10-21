class AccessTokensController < ApplicationController
  def create
    render json: { id: 1 }, status: 401
  end

  private

  def serializer
    AccessTokenSerializer
  end
end
