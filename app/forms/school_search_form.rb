# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :school_name, :location, :search_distance, :search_distance_unit, :characteristics, :partnership

  def find_schools(page)
    schools = School.where("lower(name) LIKE ? OR
                            lower(urn) LIKE ?",
                           "%#{(school_name || '').downcase}%",
                           "%#{(school_name || '').downcase}%")
    .includes(:network, :lead_provider)

    schools = schools.where(id: Partnership.pluck(:school_id)) if filter_by_partnership_status

    schools.page(page)
  end

private

  def filter_by_partnership_status
    partnership&.include? "in_a_partnership"
  end
end
