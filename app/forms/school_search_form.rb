# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :school_name,
                :location,
                :search_distance,
                :search_distance_unit,
                :characteristics,
                :partnership,
                :cohort_year,
                :lead_provider_id,
                :selected_cohort_id,
                :with_school_partnerships

  def find_schools(page)
    schools = School.eligible.where("lower(name) LIKE ? OR
                            lower(urn) LIKE ?",
                                    "%#{(school_name || '').downcase}%",
                                    "%#{(school_name || '').downcase}%")
                    .includes(:network, :lead_providers)

    schools = schools.partnered(year) if with_school_partnerships

    schools = schools.partnered_with_lead_provider(lead_provider_id) if lead_provider_id

    schools = schools.where(id: Partnership.pluck(:school_id)) if filter_by_partnership_status

    schools.page(page)
  end

private

  def filter_by_partnership_status
    partnership&.include? "in_a_partnership"
  end

  def year
    cohort_year || 2021
  end
end
