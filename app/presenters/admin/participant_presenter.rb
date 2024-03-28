# frozen_string_literal: true

class Admin::ParticipantPresenter
  attr_reader :participant_profile

  def initialize(participant_profile)
    @participant_profile = participant_profile
  end

  def all_induction_records
    induction_records
  end

  delegate :appropriate_body, to: :school_cohort, allow_nil: true

  # appropriate_body_name
  delegate :name, to: :appropriate_body, allow_nil: true, prefix: true

  def cohort
    relevant_cohort_location = relevant_induction_record&.school_cohort || relevant_induction_record&.schedule || participant_profile
    relevant_cohort_location.cohort
  end

  def declarations
    @declarations ||= @participant_profile
                        .participant_declarations
                        .includes(:cpd_lead_provider, :delivery_partner)
                        .order(created_at: :desc)
  end

  delegate :delivery_partner_name, to: :relevant_induction_record, allow_nil: true
  delegate :ect?, to: :participant_profile
  delegate :ecf_participant_eligibility, to: :participant_profile
  delegate :ecf_participant_validation_data, to: :participant_profile

  def eligibility_data
    @eligibility_data = ::EligibilityPresenter.new(@participant_profile.ecf_participant_eligibility)
  end

  def eligibility_status?
    eligibility_data.eligible_status?
  end

  delegate :email, to: :user
  delegate :enrolled_in_fip?, to: :relevant_induction_record, allow_nil: true
  delegate :full_name, to: :user

  def has_mentor?
    relevant_induction_record&.mentor&.present?
  end

  def historical_induction_records
    induction_records[1..].presence || []
  end

  delegate :id, to: :participant_profile

  def induction_completion_date
    if participant_profile.induction_completion_date
      participant_profile.induction_completion_date.to_formatted_s(:govuk)
    else
      "Not yet recorded"
    end
  end

  def induction_start_date
    if participant_profile.induction_start_date
      participant_profile.induction_start_date.to_formatted_s(:govuk)
    else
      "Not yet recorded"
    end
  end

  def is_mentor?
    mentor_profile.present?
  end

  delegate :lead_provider_name, to: :relevant_induction_record, allow_nil: true

  def mentees_by_school
    @mentees_by_school ||= ParticipantProfile::ECT
                             .merge(InductionRecord.current)
                             .joins(:induction_records)
                             .where(induction_records: { mentor_profile_id: @participant_profile.id })
                             .group_by(&:school)
  end

  # mentor_full_name
  delegate :full_name, to: :mentor_profile, allow_nil: true, prefix: :mentor

  delegate :mentor_profile, to: :relevant_induction_record, allow_nil: true
  delegate :mentor?, to: :participant_profile
  delegate :notes, to: :participant_profile
  delegate :notes?, to: :participant_profile
  delegate :participant_identities, to: :user
  delegate :participant_identity, to: :participant_profile

  def relevant_induction_record
    @relevant_induction_record ||= Induction::FindBy.new(participant_profile:).call
  end

  delegate :school, to: :school_cohort, allow_nil: true
  delegate :school_cohort, to: :relevant_induction_record, allow_nil: true

  # school_delivery_partner
  delegate :delivery_partner, to: :school_cohort, allow_nil: true, prefix: :school

  # school_delivery_partner_name
  delegate :name, to: :school_delivery_partner, allow_nil: true, prefix: true

  # school_friendly_id
  delegate :friendly_id, to: :school, allow_nil: true, prefix: true

  def school_latest_induction_record?(induction_record)
    school_latest_induction_records.include?(induction_record)
  end

  # school_lead_provider
  delegate :lead_provider, to: :school_cohort, allow_nil: true, prefix: :school

  # school_lead_provider_name
  delegate :name, to: :school_lead_provider, allow_nil: true, prefix: true

  # school_name
  delegate :name, to: :school, allow_nil: true, prefix: true

  # school_urn
  delegate :urn, to: :school, allow_nil: true, prefix: true

  delegate :start_year, to: :cohort, allow_nil: true
  delegate :status, to: :participant_profile
  delegate :teacher_profile, to: :participant_profile
  delegate :training_status, to: :participant_profile
  delegate :trn, to: :teacher_profile
  delegate :user, to: :participant_profile
  delegate :user_id, to: :participant_identity

  def user_created_at
    user&.created_at&.to_date&.to_fs(:govuk)
  end

  def validation_data
    @validation_data ||= ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile:)
  end

private

  def induction_records
    @induction_records ||= @participant_profile
      .induction_records
      .eager_load(
        :appropriate_body,
        :preferred_identity,
        :schedule,
        induction_programme: {
          partnership: :lead_provider,
          school_cohort: %i[cohort school],
        },
        mentor_profile: :user,
      )
      .inverse_induction_order
  end

  def school_latest_induction_records
    @school_latest_induction_records ||= schools.map { |school| Induction::FindBy.call(participant_profile:, school:) }
  end

  def schools
    @schools ||= School.find(induction_records.map(&:school_id).uniq)
  end
end
