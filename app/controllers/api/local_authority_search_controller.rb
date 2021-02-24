# frozen_string_literal: true

class Api::LocalAuthoritySearchController < Api::ApiController
  def index
    if params[:search_key]
      local_authorities = LocalAuthority.with_name_like(params[:search_key]).limit(10)
      render json: LocalAuthoritySerializer.render(local_authorities)
    else
      render json: []
    end
  end
end
