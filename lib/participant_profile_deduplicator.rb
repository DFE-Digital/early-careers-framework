# frozen_string_literal: true

class ParticipantProfileDeduplicator
  class DeduplicationError < RuntimeError; end

  APPLICABLE_DECLARATION_STATES = %w[submitted eligible payable paid].freeze

  attr_reader :primary_profile_id, :duplicate_profile_id, :dry_run, :changes

  def initialize(primary_profile_id, duplicate_profile_id, dry_run: true)
    @primary_profile_id = primary_profile_id
    @duplicate_profile_id = duplicate_profile_id
    @dry_run = dry_run
  end

  def dedup!
    @changes = []

    prevent_same_school_different_lead_provider_with_declarations

    log_overview_info

    warning_ect_mentor_duplicate
    warning_only_void_declarations_on_primary
    warning_training_programmes_different

    ActiveRecord::Base.transaction do
      if reconcile?
        reconcile_schedules!
        reconcile_declarations!
        transfer_validation_data!
        transfer_participant_eligibility!
        handle_school_change!
        update_mentored_ects!
        reconcile_remaining_induction_records!
      end

      delete_duplicate!

      raise ActiveRecord::Rollback if dry_run
    end

    @changes
  end

private

  def log_overview_info
    log_info("~~~ DRY RUN ~~~") if dry_run
    log_info("User: #{primary_profile.user_id}")
    log_info("Primary profile: #{primary_profile_id}")
    log_info("Duplicate profile: #{duplicate_profile_id}")
  end

  def reconcile?
    !same_school_different_lead_provider? || duplicate_has_declarations?
  end

  def same_school_different_lead_provider?
    lead_provider(primary_profile)&.id != lead_provider(duplicate_profile)&.id && school(primary_profile) == school(duplicate_profile)
  end

  def duplicate_has_declarations?
    duplicate_profile.participant_declarations.any?
  end

  def warning_training_programmes_different
    primary_training_programmes = primary_profile.induction_records.map { |ir| ir.induction_programme.training_programme }.flatten.to_set
    duplicate_training_programmes = duplicate_profile.induction_records.map { |ir| ir.induction_programme.training_programme }.flatten.to_set

    log_info("WARNING: induction programmes are different (double check primary/duplicate ordering).") if primary_training_programmes != duplicate_training_programmes
  end

  def prevent_same_school_different_lead_provider_with_declarations
    return unless same_school_different_lead_provider? && duplicate_has_declarations?

    raise DeduplicationError, "Lead provider change retaining the same school is not supported when there are declarations on the duplicate"
  end

  def warning_only_void_declarations_on_primary
    return unless primary_profile.participant_declarations.all?(&:voided?) && duplicate_profile.participant_declarations.any?(&:voidable?)

    log_info("WARNING: voided declarations on primary suggest the duplicate may be the primary. You may want to swap before continuing.")
  end

  def warning_ect_mentor_duplicate
    return unless duplicate_profile.ect? && primary_profile.mentor?

    log_info("WARNING: transition from ECT to Mentor may not indicate a duplication.")
  end

  def reconcile_schedules!
    return if primary_profile.latest_induction_record.schedule_id == duplicate_profile.latest_induction_record.schedule_id || earliest_voidable_declaration.nil?

    profile_with_correct_schedule = earliest_voidable_declaration.participant_profile
    profile_with_incorrect_schedule = profile_with_correct_schedule == primary_profile ? duplicate_profile : primary_profile

    profile_with_incorrect_schedule.participant_declarations.each(&method(:void_or_clawback_declaration))

    return if primary_profile == profile_with_correct_schedule

    update_primary_profile_schedule(profile_with_correct_schedule.latest_induction_record.schedule)
  end

  def update_mentored_ects!
    return unless [primary_profile, duplicate_profile].all?(&:mentor?)

    duplicate_profile.mentee_profiles.each do |mentee|
      mentee.update!(mentor_profile_id: primary_profile.id)
      mentee.induction_records.each { |induction_record| induction_record.update!(mentor_profile_id: primary_profile.id) }
    end
  end

  def update_primary_profile_schedule(new_schedule)
    cpd_lead_provider = lead_provider(primary_profile).cpd_lead_provider
    change_schedule = ChangeScheduleOnDuplicate.new(
      participant_id: primary_profile.user_id,
      profile: primary_profile,
      cpd_lead_provider:,
      course_identifier: determine_course_identifier(primary_profile),
      schedule_identifier: new_schedule.schedule_identifier,
      cohort: new_schedule.cohort.start_year,
    )

    raise DeduplicationError, change_schedule.errors.first.message if change_schedule.invalid?

    log_info("Changed schedule on primary profile: #{new_schedule.schedule_identifier}, #{new_schedule.cohort.start_year} (#{new_schedule.id}).")

    change_schedule.call
  end

  def determine_course_identifier(participant_profile)
    participant_profile.mentor? ? "ecf-mentor" : "ecf-induction"
  end

  def earliest_voidable_declaration
    (primary_profile.participant_declarations + duplicate_profile.participant_declarations)
      .select { |d| d.state.in?(APPLICABLE_DECLARATION_STATES) }
      .min_by(&:declaration_date)
  end

  def handle_school_change!
    return unless school(primary_profile) != school(duplicate_profile)

    primary_profile.induction_records.oldest.update!(school_transfer: true)

    log_info("Primary profile oldest induction record set as school transfer. Current school: #{school(primary_profile).urn}.")

    duplicate_induction_record = duplicate_profile.latest_induction_record
    end_date = determine_induction_record_end_date(primary_profile.induction_records.oldest, duplicate_induction_record)

    duplicate_induction_record.update!(
      participant_profile_id: primary_profile.id,
      induction_status: :leaving,
      end_date:,
      preferred_identity: preferred_identity(duplicate_induction_record),
    )

    log_info("Preferred identity updated on duplicate profile latest induction record.") if duplicate_induction_record.saved_change_to_preferred_identity_id?
    log_info("Duplicate profile latest induction record transferred. End date: #{end_date}.")
  end

  def determine_induction_record_end_date(oldest_primary_induction_record, duplicate_induction_record)
    if oldest_primary_induction_record.start_date < duplicate_induction_record.start_date
      log_info("WARNING: induction record on the duplicate profile is after the oldest induction record on the primary profile. You may want to swap before continuing.")
    end

    return duplicate_induction_record.end_date if duplicate_induction_record.end_date
    return oldest_primary_induction_record.start_date if oldest_primary_induction_record.start_date == duplicate_induction_record.start_date

    oldest_primary_induction_record.start_date - 1.minute
  end

  def reconcile_remaining_induction_records!
    duplicate_profile.induction_records.reload.each do |induction_record|
      end_date = determine_induction_record_end_date(primary_profile.induction_records.oldest, induction_record)

      induction_record.update!(
        participant_profile_id: primary_profile.id,
        preferred_identity_id: preferred_identity(induction_record).id,
        end_date:,
      )

      log_info("Preferred identity updated on duplicate profile induction record.") if induction_record.saved_change_to_preferred_identity_id?
      log_info("Duplicate profile induction record transferred. End date: #{end_date}.")
    end
  end

  def transfer_validation_data!
    return if primary_profile.ecf_participant_validation_data.present? || duplicate_profile.ecf_participant_validation_data.nil?

    log_info("Validation data transferred.")

    duplicate_profile.ecf_participant_validation_data.update!(participant_profile_id: primary_profile.id)
  end

  def transfer_participant_eligibility!
    return if primary_profile.ecf_participant_eligibility.present? || duplicate_profile.ecf_participant_eligibility.nil?

    duplicate_profile.ecf_participant_eligibility.update!(participant_profile_id: primary_profile.id)

    log_info("Eligibility transferred.")
  end

  def reconcile_declarations!
    duplicate_profile.participant_declarations.each do |declaration|
      void_most_recent_conflicting_declaration!(declaration)
      declaration.update!(
        participant_profile_id: primary_profile.id,
        user_id: primary_profile.user_id,
      )

      log_info("User changed on declaration (#{declaration.id}).") if declaration.saved_change_to_user_id?
      log_info("Transferred declaration: #{declaration.declaration_type}, #{declaration.state} (#{declaration.id}).")
    end
  end

  def void_most_recent_conflicting_declaration!(declaration)
    conflicting_declaration = conflicting_declaration(declaration)

    return unless conflicting_declaration

    most_recent_declaration = [declaration, conflicting_declaration].max_by(&:declaration_date)
    void_or_clawback_declaration(most_recent_declaration)
  end

  def void_or_clawback_declaration(declaration)
    return unless declaration.voidable? || declaration.paid?

    log_info("Voided declaration: #{declaration.declaration_type}, #{declaration.state} (#{declaration.id}).")
    VoidParticipantDeclaration.new(declaration).call
  end

  def conflicting_declaration(declaration)
    return unless declaration.state.in?(APPLICABLE_DECLARATION_STATES)

    primary_profile.participant_declarations.find do |d|
      d.declaration_type == declaration.declaration_type && d.state == declaration.state
    end
  end

  def delete_duplicate!
    Finance::ECF::DeletedDuplicate.create!(
      data: serialized_duplicate,
      primary_participant_profile: primary_profile,
    )

    log_info("Destroyed duplicate profile.")

    duplicate_profile.reload
    duplicate_profile.validation_decisions.destroy_all
    duplicate_profile.participant_profile_states.destroy_all
    duplicate_profile.participant_profile_schedules.destroy_all
    duplicate_profile.induction_records.destroy_all
    duplicate_profile.ecf_participant_validation_data&.destroy!
    duplicate_profile.ecf_participant_eligibility&.destroy!
    duplicate_profile.destroy!
  end

  def serialized_duplicate
    @serialized_duplicate ||= Finance::ECF::DuplicateSerializer.new(duplicate_profile).serializable_hash
  end

  def primary_profile
    @primary_profile ||= ParticipantProfile::ECF.find(primary_profile_id)
  end

  def duplicate_profile
    @duplicate_profile ||= ParticipantProfile::ECF.find(duplicate_profile_id)
  end

  def school(participant_profile)
    participant_profile.latest_induction_record&.school || participant_profile.school
  end

  def lead_provider(participant_profile)
    participant_profile.latest_induction_record&.lead_provider || participant_profile.lead_provider
  end

  def preferred_identity(duplicate_induction_record)
    if duplicate_induction_record.preferred_identity&.user_id == primary_profile.induction_records.oldest.preferred_identity.user_id
      duplicate_induction_record.preferred_identity
    else
      primary_profile.latest_induction_record.preferred_identity
    end
  end

  def log_info(info)
    changes << info
    Rails.logger.info(info)
  end
end
