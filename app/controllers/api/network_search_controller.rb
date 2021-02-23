# frozen_string_literal: true

class Api::NetworkSearchController < Api::ApiController
  def index
    if params[:search_key]
      networks = Network.with_name_like(params[:search_key]).limit(10)
      render json: NetworkSerializer.render(networks)
    else
      render json: []
    end
  end
end
