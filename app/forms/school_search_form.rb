# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  CHARACTERISTICS = [OpenStruct.new(id: "pupil_premium_above_40", name: "Pupil premium above 40%"),
                     OpenStruct.new(id: "top_20_remote_areas", name: "Located in top 20% most remote areas")].freeze

  attr_accessor :school_name, :location, :search_distance, :search_distance_unit, :characteristics, :partnership, :search_type

  def find_schools(page)
    schools = School.where("schools.name ILIKE ? OR schools.urn ILIKE ?", "%#{school_name || ''}%", "%#{school_name || ''}%")
                    .includes(:network, :lead_provider)

    schools = schools.where.not(id: Partnership.pluck(:school_id)) unless filter_by_partnership_status

    if pp && sparse
      schools = schools.with_pupil_premium_uplift(2021).or(schools.with_sparsity_uplift(2021))
    elsif pp
      schools = schools.with_pupil_premium_uplift(2021)
    elsif sparse
      schools = schools.with_sparsity_uplift(2021)
    end

    schools.page(page)
  end

private

  def filter_by_partnership_status
    partnership&.include? "in_a_partnership"
  end

  def pp
    characteristics&.include? "pupil_premium_above_40"
  end

  def sparse
    characteristics&.include? "top_20_remote_areas"
  end
end
