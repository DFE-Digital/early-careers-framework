# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :school_name, :location, :search_distance, :search_distance_unit, :characteristics, :partnership

  def find_schools(page)
    if partnership&.include? "partnered_with_another_provider"
      School.where(id: Partnership.select(:school_id).map(&:school_id)).page(page)
    else
      School.where("lower(name) LIKE ? OR lower(urn) LIKE ?", "%#{(school_name || '').downcase}%", "%#{(school_name || '').downcase}%").includes(
        :network, :lead_provider
      ).page(page)
    end
  end
end
