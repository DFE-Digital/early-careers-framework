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
                :search_type,
                :cohort_year,
                :lead_provider_id,
                :selected_cohort_id

  def find_schools(page)
    schools = School.where("schools.name ILIKE ? OR schools.urn ILIKE ?", "%#{school_name || ''}%", "%#{school_name || ''}%")
                    .includes(:network, :lead_providers)

    schools = schools.unpartnered(year) unless show_partnered?

    schools = schools.partnered(year) if show_partnered?

    schools = schools.partnered_with_lead_provider(lead_provider_id) if lead_provider_id

    schools = schools.with_local_authority(local_authorities) if local_authorities&.reject(&:blank?)&.any?

    schools = schools.where(network: networks) if networks&.reject(&:blank?)&.any?

    if only_pupil_premium? && only_sparse?
      schools = schools.with_pupil_premium_uplift(year).or(schools.with_sparsity_uplift(year))
    elsif only_pupil_premium?
      schools = schools.with_pupil_premium_uplift(year)
    elsif only_sparse?
      schools = schools.with_sparsity_uplift(year)
    end

    schools.page(page)
  end

  def local_authority_options
    LocalAuthority.all
  end

  def network_options
    Network.all
  end

  def year
    cohort_year || 2021
  end

private

  def show_partnered?
    partnership&.include? "in_a_partnership"
  end

  def only_pupil_premium?
    characteristics&.include? "pupil_premium_above_40"
  end

  def only_sparse?
    characteristics&.include? "top_20_remote_areas"
  end
end
