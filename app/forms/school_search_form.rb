# frozen_string_literal: true

class SchoolSearchForm
  include ActiveModel::Model

  CHARACTERISTICS = [OpenStruct.new(id: "pupil_premium_above_40", name: "Pupil premium above 40%"),
                     OpenStruct.new(id: "top_20_remote_areas", name: "Located in remote area")].freeze

  attr_accessor :school_name,
                :location,
                :search_distance,
                :search_distance_unit,
                :characteristics,
                :partnership,
                :local_authorities,
                :networks,
                :search_type

  def find_schools(page)
    schools = School.where("schools.name ILIKE ? OR schools.urn ILIKE ?", "%#{school_name || ''}%", "%#{school_name || ''}%")
                    .includes(:network, :lead_providers)

    schools = schools.where.not(id: Partnership.pluck(:school_id)) unless filter_by_partnership_status

    schools = schools.with_local_authority(local_authorities) if local_authorities&.reject(&:blank?)&.any?

    schools = schools.where(network: networks) if networks&.reject(&:blank?)&.any?

    if pp && sparse
      schools = schools.with_pupil_premium_uplift(2021).or(schools.with_sparsity_uplift(2021))
    elsif pp
      schools = schools.with_pupil_premium_uplift(2021)
    elsif sparse
      schools = schools.with_sparsity_uplift(2021)
    end

    schools.page(page)
  end

  def local_authority_options
    LocalAuthority.all
  end

  def network_options
    Network.all
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
