class AnalyzesController < ApplicationController
  def create
    text = params[:text]

    if text.blank?
      render json: { error: "text パラメータは必須です" }, status: :bad_request
      return
    end

    @result = TextAnalyzer.new(text).call
  end
end
