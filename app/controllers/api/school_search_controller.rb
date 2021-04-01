# frozen_string_literal: true

class Api::SchoolSearchController < Api::ApiController
  def index
    if params[:search_key]
      schools = School.eligible.search_by_name_or_urn(params[:search_key]).limit(10)
      decorated_schools = schools.map { |school| ::Decorators::SchoolDecorator.new(school) }
      render json: SchoolSerializer.render(decorated_schools)
    else
      render json: []
    end
  end
end
