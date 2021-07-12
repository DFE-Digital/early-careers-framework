# frozen_string_literal: true

class Api::SchoolSearchController < Api::ApiController
  def index
    if params[:search_key]
      schools = School
        .eligible
        .ransack(name_or_urn_cont: params[:search_key]).result
        .limit(10)
      decorated_schools = schools.map { |school| SchoolDecorator.new(school) }
      render json: SchoolSerializer.render(decorated_schools)
    else
      render json: []
    end
  end
end
