class SessionsController < ApplicationController
  def show
    render json: { message: "疎通確認OK" }, status: :ok
  end
end
