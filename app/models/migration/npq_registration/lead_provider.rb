class Migration::NPQRegistration::LeadProvider < Migration::NPQRegistration::BaseRecord
  ALL_PROVIDERS = {
    "Ambition Institute" => "9e35e998-c63b-4136-89c4-e9e18ddde0ea",
    "Best Practice Network (home of Outstanding Leaders Partnership)" => "57ba9e86-559f-4ff4-a6d2-4610c7259b67",
    "Church of England" => "79cb41ca-cb6d-405c-b52c-b6f7c752388d",
    "Education Development Trust" => "21e61f53-9b34-4384-a8f5-d8224dbf946d",
    "LLSE" => "230e67c0-071a-4a48-9673-9d043d456281",
    "National Institute of Teaching" => "3ec607f2-7a3a-421f-9f1a-9aca8a634aeb",
    "School-Led Network" => "bc5e4e37-1d64-4149-a06b-ad10d3c55fd0",
    "Teacher Development Trust" => "30fd937e-b93c-4f81-8fff-3c27544193f1",
    "Teach First" => "a02ae582-f939-462f-90bc-cebf20fa8473",
    "UCL Institute of Education" => "ef687b3d-c1c0-4566-a295-16d6fa5d0fa7",
  }.freeze

  NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS = [
    "Ambition Institute",
    "Best Practice Network (home of Outstanding Leaders Partnership)",
    "Church of England",
    "Education Development Trust",
    "LLSE",
    "National Institute of Teaching",
    "Teacher Development Trust",
    "Teach First",
    "UCL Institute of Education",
  ].freeze

  EYL_LL_PROVIDERS = [
    "Ambition Institute",
    "Education Development Trust",
    "National Institute of Teaching",
    "Teacher Development Trust",
    "Teach First",
    "UCL Institute of Education",
  ].freeze

  EL_PROVIDERS = [
    "Ambition Institute",
    "Best Practice Network (home of Outstanding Leaders Partnership)",
    "Church of England",
    "Education Development Trust",
    "LLSE",
    "National Institute of Teaching",
    "Teacher Development Trust",
    "Teach First",
    "UCL Institute of Education",
  ].freeze

  LPM_PROVIDERS = [
    "Ambition Institute",
    "Church of England",
    "Education Development Trust",
    "LLSE",
    "Teach First",
    "UCL Institute of Education",
    "National Institute of Teaching",
  ].freeze

  # TODO: Move all of this mapping into the database
  #       Hardcoding this has been done for expediency but
  #       longterm having this handled in the DB so none of
  #       this data has to be hardcoded would be preferable.
  COURSE_TO_PROVIDER_MAPPING = {
    "npq-headship" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-senior-leadership" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-leading-teaching" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-leading-teaching-development" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-leading-behaviour-culture" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-early-headship-coaching-offer" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,
    "npq-additional-support-offer" => NPQH_SL_LT_LTD_LBC_EHCO_PROVIDERS,

    "npq-early-years-leadership" => EYL_LL_PROVIDERS,
    "npq-leading-literacy" => EYL_LL_PROVIDERS,

    "npq-executive-leadership" => EL_PROVIDERS,

    "npq-leading-primary-mathematics" => LPM_PROVIDERS,
  }.freeze

  scope :alphabetical, -> { order(name: :asc) }

  def self.for(course:)
    course_specific_list = COURSE_TO_PROVIDER_MAPPING[course.identifier]

    return all if course_specific_list.blank?

    ecf_ids = ALL_PROVIDERS.slice(*course_specific_list).values.compact_blank
    raise "Missing provider ECF_ID for available providers list" if ecf_ids.count != course_specific_list.count

    where(ecf_id: ecf_ids)
  end
end
