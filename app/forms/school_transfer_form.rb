# frozen_string_literal: true

class SchoolTransferForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  attr_accessor :current_step, :participant_profile_id, :new_school_urn, :transfer_choice, :start_date, :email

  STEPS = %i[select_school transfer_options start_date email check_answers].freeze

  validate :participant_profile_present
  validates :new_school_urn, presence: true, on: :select_school
  validate :new_school_exists, on: :select_school
  validate :start_date_is_valid, on: :start_date
  validates :email, presence: true, notify_email: true, on: :email
  validate :email_is_not_in_use, on: :email
  validates :transfer_choice, presence: true, on: :transfer_options

  def attributes
    {
      participant_profile_id:,
      new_school_urn:,
      start_date:,
      email:,
      transfer_choice:,
    }
  end

  def next_step
    return if current_step == STEPS.last

    step = nil
    STEPS.each_with_index do |step_name, i|
      step = STEPS[i + 1] and break if step_name == current_step
    end
    step
  end

  def previous_step
    return if current_step == STEPS.first

    step = nil
    STEPS.each_with_index do |step_name, i|
      step = STEPS[i - 1] and break if step_name == current_step
    end
    step
  end

  def current_school
    @current_school ||= latest_induction_record.school
  end

  def current_programme
    @current_programme ||= latest_induction_record.induction_programme
  end

  def current_programme_description
    make_programme_description(current_programme)
  end

  def participant_cohort
    participant_profile.schedule.cohort
  end

  def new_school
    @new_school ||= School.find_by(urn: new_school_urn)
  end

  def new_school_cohort
    @new_school_cohort ||= new_school.school_cohorts.find_by(cohort: participant_cohort)
  end

  def chosen_programme
    InductionProgramme.find(transfer_choice) unless continue_existing_programme?
  end

  def perform_transfer!
    if continue_existing_programme?
      # create a new programme at the school and join
      Induction::TransferAndContinueExistingProgramme.call(school: new_school, participant_profile:, start_date:, email:)
    else
      # join an existing programme at the school
      Induction::TransferToSchoolsProgramme.call(participant_profile:, induction_programme: chosen_programme, start_date:, email:)
    end
  end

  def cannot_transfer_to_new_school?
    cannot_transfer_reason.present?
  end

  def cannot_transfer_reason
    if new_school_cohort.blank?
      "they have not chosen a programme for #{participant_cohort.start_year}"
    elsif new_school_cohort.induction_programmes.full_induction_programme.empty? && new_school_cohort.induction_programmes.core_induction_programmes.empty?
      "they do not have any FIP or CIP induction programmes for #{participant_cohort.start_year}"
    end
  end

  def transfer_choice_description
    if transfer_choice == "continue"
      "Continue with existing programme"
    else
      make_programme_description(InductionProgramme.find(transfer_choice))
    end
  end

  def transfer_options
    programmes = []
    programmes << new_school_cohort.default_induction_programme if new_school_cohort.default_induction_programme.present?

    new_school_cohort.induction_programmes.where.not(id: new_school_cohort.default_induction_programme).each { |ip| programmes << ip }

    programmes.select { |ip| ip.full_induction_programme? || ip.core_induction_programme? }.map do |induction_programme|
      OpenStruct.new(id: induction_programme.id, description: make_programme_description(induction_programme))
    end
  end

  def participant_name
    participant_profile.user.full_name
  end

  def latest_induction_record
    @latest_induction_record ||= participant_profile.induction_records.latest
  end

  def continue_existing_programme?
    transfer_choice == "continue"
  end

private

  def participant_profile
    @participant_profile ||= ParticipantProfile.find(participant_profile_id)
  end

  def participant_profile_present
    raise "Participant profile id missing" if participant_profile_id.blank?
  end

  def partnership_details(induction_programme)
    if induction_programme.partnership.present?
      "with #{induction_programme.lead_provider.name}/#{induction_programme.delivery_partner&.name || 'no delivery partner'}"
    else
      "- no partnership in place"
    end
  end

  def materials_details(induction_programme)
    if induction_programme.core_induction_programme.present?
      "using #{induction_programme.core_induction_programme.name} materials"
    else
      "- no materials chosen"
    end
  end

  def make_programme_description(induction_programme)
    is_default = induction_programme.id == new_school_cohort.default_induction_programme&.id

    if induction_programme.full_induction_programme?
      "FIP #{partnership_details(induction_programme)} #{is_default ? '(cohort default)' : ''}"
    else
      "CIP #{materials_details(induction_programme)} #{is_default ? '(cohort default)' : ''}"
    end
  end

  def new_school_exists
    errors.add(:new_school_urn, :invalid, urn: new_school_urn) if new_school.nil?
  end

  def start_date_is_valid
    @start_date = ActiveRecord::Type::Date.new.cast(start_date)
    if @start_date.blank?
      errors.add(:start_date, :blank)
    elsif @start_date.year.digits.length != 4
      errors.add(:start_date, :invalid)
    # elsif @start_date < participant_profile.schedule.milestones.first.start_date
    elsif @start_date < latest_induction_record.start_date
      errors.add(:start_date, :before_start, date: latest_induction_record.start_date.to_date.to_s(:govuk))
    end
  end

  def email_is_not_in_use
    user = Identity.find_user_by(email:)
    if user.present? && user != participant_profile.user
      errors.add(:email, :taken)
    end
  end
end
