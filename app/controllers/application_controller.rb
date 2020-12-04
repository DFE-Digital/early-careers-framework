class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def check
    render json: { status: "OK" }, status: :ok
  end
end
