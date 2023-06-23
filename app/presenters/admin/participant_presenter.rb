# frozen_string_literal: true

class Admin::ParticipantPresenter
  attr_reader :participant_profile

  delegate :id,
           :user,
           :participant_identity,
           :training_status,
           :status,
           :notes,
           :notes?,
           :ect?,
           :mentor?,
           :ecf_participant_validation_data,
           :ecf_participant_eligibility,
           :teacher_profile,
           to: :participant_profile

  delegate :full_name, :email, :participant_identities, to: :user
  delegate :user_id, to: :participant_identity
  delegate :trn, to: :teacher_profile

  def initialize(participant_profile)
    @participant_profile = participant_profile
  end

  def relevant_induction_record
    @relevant_induction_record ||= Induction::FindBy.new(participant_profile:).call
  end

  def school_cohort
    relevant_induction_record&.school_cohort
  end

  def school
    school_cohort&.school
  end

  def cohort
    school_cohort&.cohort
  end

  def start_year
    cohort&.start_year
  end

  def school_name
    school&.name
  end

  def school_urn
    school&.urn
  end

  def school_friendly_id
    school&.friendly_id
  end

  def lead_provider_name
    school_cohort&.lead_provider&.name
  end

  def delivery_partner_name
    school_cohort&.delivery_partner&.name
  end

  def appropriate_body_name
    school_cohort&.appropriate_body&.name
  end

  def historical_induction_records
    induction_records[1..].presence || []
  end

  def all_induction_records
    induction_records
  end

  def has_mentor?
    relevant_induction_record&.mentor&.present?
  end

  def is_mentor?
    mentor_profile.present?
  end

  def mentor_profile
    relevant_induction_record&.mentor_profile
  end

  def mentor_full_name
    mentor_profile&.full_name
  end

  def user_created_at
    user&.created_at&.to_date&.to_fs(:govuk)
  end

  def mentees_by_school
    @mentees_by_school ||= ParticipantProfile::ECT
      .merge(InductionRecord.current)
      .joins(:induction_records)
      .where(induction_records: { mentor_profile_id: @participant_profile.id })
      .group_by(&:school)
  end

  def declarations
    @declarations ||= @participant_profile
      .participant_declarations
      .includes(:cpd_lead_provider, :delivery_partner)
      .order(created_at: :desc)
  end

  def validation_data
    @validation_data ||= ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile:)
  end

  def eligibility_data
    @eligibility_data = ::EligibilityPresenter.new(@participant_profile.ecf_participant_eligibility)
  end

  def eligibility_status?
    eligibility_data.eligible_status?
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
      .order(start_date: :desc, created_at: :desc)
  end
end
