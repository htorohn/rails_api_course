class AccessTokensController < ApplicationController
  def create
    # render json: AccessToken.all, status: 401
    authenticator = UserAuthenticator.new(params[:code])
    authenticator.perform
    render json: access_token
  end

  private

  def serializer
    AccessTokenSerializer
  end
end
