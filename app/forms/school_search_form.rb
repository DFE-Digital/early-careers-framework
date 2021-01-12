# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :school_name, :location, :search_distance, :search_distance_unit, :characteristics, :partnership

  def find_schools(page)
    School.where(
      "lower(name) like ?", "%#{(school_name || '').downcase}%"
    ).includes(
      :network, :lead_provider
    ).page(page)
  end
end
