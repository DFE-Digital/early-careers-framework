# frozen_string_literal: true

class ParticipantEventHistory
  class ParticipantEvent
    attr_reader :date, :description, :reporter

    def initialize(date, description, reporter)
      @date = date
      @description = description
      @reporter = reporter
    end
  end

  attr_reader :events

  def initialize(user)
    @user = user
    @events = []

    record_user_events @user unless @user.nil?
    record_teacher_record_events @user.teacher_profile unless @user.teacher_profile.nil?

    @user.participant_identities.each { |identity| record_identity_events(identity) } unless @user.participant_identities.empty?

    unless @user.participant_profiles.empty?
      @user.participant_profiles.each do |profile|
        record_profile_events(profile)
        induction_records = profile.induction_records.sort_by { |record| [record.start_date, record.end_date.nil?, record.end_date] }

        record_induction_record_events(induction_records) unless profile.induction_records.empty?
        record_participant_declaration_events(profile.participant_declarations.sort_by(&:created_at))

        next unless profile.ecf?

        record_validation_events(profile.ecf_participant_validation_data) unless profile.ecf_participant_validation_data.nil?
        record_eligibility_events(profile.ecf_participant_eligibility) unless profile.ecf_participant_eligibility.nil?

        record_validation_decision_events(profile.validation_decisions) unless profile.validation_decisions.nil?

        # if profile.mentor?
        # profile.school_mentors
        # end
      end
    end

    @events.sort_by!(&:date)
  end

  def self.from_profile(profile)
    new(profile.user)
  end

  def self.from_user(user)
    new(user)
  end

private

  def record_user_events(user)
    @events.push ParticipantEvent.new(user.created_at, "Registered with the system", user.school&.name || "Unknown")

    user.versions&.each do |version|
      version.object_changes&.each do |key, value|
        description = user_event_description(key, value)
        unless description.nil?
          @events.push ParticipantEvent.new(version.created_at, description, version.whodunnit || "Unknown")
        end
      end
    end
  end

  def user_event_description(key, _value)
    case key
    when "login_token"
      "Logged in"
    when "email"
      "Changed email address"
    when "full_name"
      "Changed name"
    when "discarded_at"
      "Removed from the system"
    when "created_at"
      nil
    when "updated_at"
      nil
    else
      "User.#{key}"
    end
  end

  def record_teacher_record_events(teacher_record)
    @events.push ParticipantEvent.new(teacher_record.created_at, "Teacher record created", teacher_record.school&.name || "Unknown")

    teacher_record.versions&.each do |version|
      version.object_changes&.each do |key, value|
        description = teacher_record_event_description(key, value)
        unless description.nil?
          @events.push ParticipantEvent.new(version.created_at, description, version.whodunnit || "Unknown")
        end
      end
    end
  end

  def teacher_record_event_description(key, value)
    case key
    when "trn"
      "TRN #{value.nil? ? 'removed' : 'updated'}"
    when "school_id"
      "Transferred to another school"
    when "user_id"
      "TeacherProfile reassigned to a different user"
    when "created_at"
      nil
    when "updated_at"
      nil
    else
      "TeacherRecord.#{key}"
    end
  end

  def record_profile_events(profile)
    @events.push ParticipantEvent.new(profile.created_at, "Participant Profile created", profile.school&.name || "Unknown")

    profile.versions&.each do |version|
      version.object_changes&.each do |key, value|
        description = profile_event_description(key, value)
        unless description.nil?
          @events.push ParticipantEvent.new(version.created_at, description, version.whodunnit || "Unknown")
        end
      end
    end
  end

  def profile_event_description(key, value)
    case key
    when "type"
      "Participant became a #{value.new}"
    when "core_induction_programme_id"
      "Switched induction programme"
    when "cohort_id"
      "Moved to a different cohort"
    when "mentor_profile_id"
      "New Mentor assigned"
    when "status"
      "Participant was #{value.new}"
    when "school_cohort_id"
      "Moved to a different cohort"
    when "teacher_profile_id"
      "New Teacher Record identified"
    when "schedule_id"
      "Switched Schedule"
    when "npq_course_id"
      "NPQ Course change"
    when "school_urn"
      "Transferred to another school"
    when "school_ukprn"
      nil
    when "request_for_details_sent_at"
      "Validation request sent"
    when "training_status"
      "Training status changed to #{value.new}"
    when "notes"
      nil
    when "created_at"
      nil
    when "updated_at"
      nil
    else
      "Participation.#{key}"
    end
  end

  def record_identity_events(identity)
    # identity is not auditable
    @events.push ParticipantEvent.new(identity.created_at, "Identity created", "Unknown")
  end

  def record_induction_record_events(induction_records)
    @events.push ParticipantEvent.new(induction_records.first.created_at, "InductionRecords started", "Unknown")

    induction_records.each_with_index do |record, index|
      next_record = induction_records[index]
      next if next_record.nil?

      record.attributes.each do |key, value|
        description = induction_record_event_description(key, next_record[key], value)
        unless description.nil? || next_record[key] == value
          @events.push ParticipantEvent.new(next_record.created_at, description, "Unknown")
        end
      end
    end
  end

  def induction_record_event_description(key, value_new, _value_old)
    case key
    when "induction_programme_id"
      "Switched induction programme"
    when "participant_profile_id"
      "Induction Records assigned to new Participation"
    when "schedule_id"
      "Switched Schedule"
    when "start_date"
      nil
    when "end_date"
      nil
    when "training_status"
      "Training status changed to #{value_new}"
    when "preferred_identity_id"
      "Preferred Identity changed"
    when "induction_status"
      if value_new == "changed"
        nil
      else
        "Training status changed to #{value_new}"
      end
    when "mentor_profile_id"
      "New Mentor assigned"
    when "school_transfer"
      "School transfer reported"
    when "appropriate_body_id"
      "New Appropriate Body assigned"
    when "created_at"
      nil
    when "updated_at"
      nil
    else
      "InductionRecords.#{key}"
    end
  end

  def record_participant_declaration_events(declarations)
    declarations.each do |declaration|
      @events.push ParticipantEvent.new(declaration.declaration_date, "#{declaration.declaration_type} milestone reached", declaration.cpd_lead_provider.name)

      declaration.declaration_states.each do |declaration_state|
        @events.push ParticipantEvent.new(declaration_state.created_at, "#{declaration.declaration_type} declaration #{%w[submitted paid].exclude?(declaration_state.state) ? 'made ' : ' '}#{declaration_state.state}", declaration.cpd_lead_provider.name)
      end
    end
  end

  def record_validation_events(validation_data)
    # validation_data is not auditable
    if !validation_data.trn.nil? || !validation_data.full_name.nil? || !validation_data.nino.nil? || !validation_data.date_of_birth.nil?
      @events.push ParticipantEvent.new(validation_data.created_at, "Validation data provided", validation_data.full_name)
    end
  end

  def record_eligibility_events(eligibility)
    @events.push ParticipantEvent.new(eligibility.created_at, "Eligibility status changed to #{eligibility.status}", "System")

    eligibility.versions&.each do |version|
      version.object_changes&.each do |key, value|
        if key == :state
          @events.push ParticipantEvent.new(version.created_at, "Eligibility status changed to #{value.new}", version.whodunnit || "Unknown")
        end
      end
    end
  end

  def record_validation_decision_events(decisions)
    decisions.each do |decision|
      @events.push ParticipantEvent.new(decision.created_at, decision.approved, "System")

      decision.versions&.each do |version|
        version.object_changes&.each do |key, value|
          if key == :state
            @events.push ParticipantEvent.new(version.created_at, value.new ? "Validation approved" : "Validation not-approved", version.whodunnit || "Unknown")
          end
        end
      end
    end
  end
end
