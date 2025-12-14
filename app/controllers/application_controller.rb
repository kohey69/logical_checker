class ApplicationController < ActionController::API
  before_action :authenticate!

  attr_reader :current_user

  private

  def authenticate!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")&.strip

    @current_user = User.find_by(api_token: token)

    unless @current_user
      render json: { error: "認証できませんでした" }, status: :unauthorized
    end
  end
end
