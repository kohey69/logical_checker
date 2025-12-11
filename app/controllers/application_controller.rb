class ApplicationController < ActionController::API
  before_action :authenticate!

  attr_reader :current_user

  private

  def authenticate!
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last

    @current_user = User.find_by(api_token: token)

    unless @current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
