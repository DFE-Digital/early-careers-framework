class Migration::NPQRegistration::School < Migration::NPQRegistration::BaseRecord
  PRIMARY_PHASE = "Primary".freeze
  MIDDLE_DEEMED_PRIMARY_PHASE = "Middle deemed primary".freeze

  # 1 => establishment_status_name: "Open"
  # 2 => establishment_status_name: "Closed"
  # 3 => establishment_status_name: "Open, but proposed to close"
  # 4 => establishment_status_name: "Proposed to open"

  scope :open, -> { where(establishment_status_code: %w[1 3 4]) }

  def display_name
    name
  end

  def primary_education_phase?
    phase_name == MIDDLE_DEEMED_PRIMARY_PHASE ||
      phase_name == PRIMARY_PHASE
  end

  def address
    [address_1, address_2, address_3, town, county, postcode].reject(&:blank?)
  end

  def address_string
    address.join(", ")
  end

  def name_with_address
    [display_name, address_string].join(" – ")
  end

  def in_england?
    return if establishment_type_code == "30" # Welsh establishment
    return if la_code == "673" # "Vale of Glamorgan"
    return if la_code == "702" # "BFPO Overseas Establishments"
    return if la_code == "000" # "Does not apply"
    return if la_code == "704" # "Fieldwork Overseas Establishments"
    return if la_code == "708" # "Gibraltar Overseas Establishments"

    true
  end

  def identifier
    "School-#{urn}"
  end

  def eligible_establishment?
    eligible_establishment_type_codes.include?(establishment_type_code)
  end

private

  def eligible_establishment_type_codes
    [
      1, # Community school
      2, # Voluntary aided school
      3, # Voluntary controlled school
      5, # Foundation school
      6, # City technology college
      7, # Community special school
      8, # Non-maintained special school
      10, # Other independent special school
      12, # Foundation special school
      14, # Pupil referral unit
      15, # Local authority nursery school
      18, # Further education
      24, # Secure units
      26, # Service children's education
      28, # Academy sponsor led
      31, # Sixth form centres
      32, # Special post 16 institution
      33, # Academy special sponsor led
      34, # Academy converter
      35, # Free schools
      36, # Free schools special
      38, # Free schools alternative provision
      39, # Free schools 16 to 19
      40, # University technical college
      41, # Studio schools
      42, # Academy alternative provision converter
      43, # Academy alternative provision sponsor led
      44, # Academy special converter
      45, # Academy 16-19 converter
      46, # Academy 16 to 19 sponsor led
    ].map(&:to_s)
  end
end
