# frozen_string_literal: true

class ParticipantProfileDeduplicator
  class DeduplicationError < RuntimeError; end

  CONFLICTING_DECLARATION_STATES = %w[submitted eligible payable paid].freeze

  attr_reader :primary_profile_id, :duplicate_profile_id, :dry_run, :changes

  def initialize(primary_profile_id, duplicate_profile_id, dry_run: true)
    @primary_profile_id = primary_profile_id
    @duplicate_profile_id = duplicate_profile_id
    @dry_run = dry_run
  end

  def dedup!
    @changes = []

    log_info("~~~ DRY RUN ~~~") if dry_run

    warning_ect_mentor_duplicate
    warning_only_void_declarations_on_primary

    prevent_same_school_different_lead_provider
    ensure_schedules_match
    ensure_training_programmes_match

    ActiveRecord::Base.transaction do
      reconcile_declarations!
      transfer_validation_data!
      transfer_participant_eligibility!
      handle_school_change!
      reconcile_remaining_induction_records!
      delete_duplicate!

      raise ActiveRecord::Rollback if dry_run
    end

    @changes
  end

private

  def prevent_same_school_different_lead_provider
    return unless primary_profile.lead_provider&.id != duplicate_profile.lead_provider&.id && primary_profile.school == duplicate_profile.school

    raise DeduplicationError, "Different lead providers at the same school are not yet supported."
  end

  def ensure_schedules_match
    return if primary_profile.latest_induction_record.schedule_id == duplicate_profile.latest_induction_record.schedule_id

    raise DeduplicationError, "Only duplicates with the same schedule are supported."
  end

  def ensure_training_programmes_match
    primary_training_programmes = primary_profile.induction_records.map { |ir| ir.induction_programme.training_programme }.flatten
    duplicate_training_programmes = duplicate_profile.induction_records.map { |ir| ir.induction_programme.training_programme }.flatten

    raise DeduplicationError, "Only duplicates with the same training programme are supported." if primary_training_programmes.difference(duplicate_training_programmes).any?
  end

  def warning_only_void_declarations_on_primary
    return unless primary_profile.participant_declarations.all?(&:voided?) && duplicate_profile.participant_declarations.any?(&:voidable?)

    log_info("WARNING: voided declarations on primary suggest the duplicate may be the primary. You may want to swap before continuing.")
  end

  def warning_ect_mentor_duplicate
    return unless duplicate_profile.is_a?(ParticipantProfile::ECT) && primary_profile.is_a?(ParticipantProfile::Mentor)

    log_info("WARNING: transition from ECT to Mentor may not indicate a duplication.")
  end

  def handle_school_change!
    return unless primary_profile.school != duplicate_profile.school

    primary_profile.induction_records.oldest.update!(school_transfer: true)

    log_info("Primary profile oldest induction record set as school transfer.")

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

    most_recent_declaration = [declaration, conflicting_declaration].max_by(&:created_at)
    log_info("Voided conflicting declaration: #{most_recent_declaration.declaration_type}, #{most_recent_declaration.state} (#{most_recent_declaration.id}).")
    VoidParticipantDeclaration.new(most_recent_declaration).call
  end

  def conflicting_declaration(declaration)
    return unless declaration.state.in?(CONFLICTING_DECLARATION_STATES)

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
