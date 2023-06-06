# frozen_string_literal: true

# noinspection RubyInstanceMethodNamingConvention
class Participants::HistoryBuilder
  class ParticipantEvent
    attr_reader :object, :date, :predicate, :reporter, :value

    def initialize(id, date, predicate, reporter, value)
      @object = id
      @predicate = predicate
      @value = value
      @date = date
      @reporter = reporter
    end

    def to_h
      {
        object:,
        predicate:,
        value:,
        date:,
        reporter:,
      }
    end
  end

  attr_reader :events

  def initialize(user)
    @user = user
    @events = []

    # TODO: paper trail entities to investigate for other relevant events
    # - InductionCoordinatorProfile ( showing when a new SIT took over )
    # - SchoolMentors ( what schools the participant is a mentor for )

    return if @user.nil?

    record_user_events @user
    # record_teacher_record_events @user.teacher_profile unless @user.teacher_profile.nil?

    @user.participant_identities.each { |identity| record_identity_events(identity) } unless @user.participant_identities.empty?

    unless @user.participant_profiles.empty?
      @user.participant_profiles.each do |profile|
        record_profile_events(profile)
        record_participant_declaration_events(profile.participant_declarations.sort_by(&:created_at))

        # the following are only relevant to ECF profiles
        next unless profile.ecf?

        record_validation_events(profile.ecf_participant_validation_data) unless profile.ecf_participant_validation_data.nil?
        record_validation_decision_events(profile.validation_decisions) unless profile.validation_decisions.empty?
        record_eligibility_events(profile.ecf_participant_eligibility) unless profile.ecf_participant_eligibility.nil?

        # not all ECF Participants have induction records !!
        record_induction_record_events(profile.induction_records.oldest_first) unless profile.induction_records.empty?
      end
    end

    @events.sort_by! { |ev| [ev.date.to_i, ev.predicate] }
  end

  def self.from_participant_profile(profile)
    new(profile.user)
  end

  def self.from_user(user)
    new(user)
  end

private

  def record_user_events(user)
    if user.versions.empty?
      record_created_event(user, user.school&.name)
    else
      record_paper_trail_events(user)
    end
  end

  def record_teacher_record_events(teacher_record)
    if teacher_record.versions.empty?
      record_created_event(teacher_record, teacher_record.user.school&.name)
    else
      record_paper_trail_events(teacher_record)
    end
  end

  def record_profile_events(participant_profile)
    if participant_profile.versions.empty?
      record_created_event(participant_profile, participant_profile.school&.name)
    else
      record_paper_trail_events(participant_profile)
    end
  end

  def record_identity_events(identity)
    @events.push ParticipantEvent.new(@user.id, identity.created_at, "#{identity.class}.email", "Unknown", "email-hidden")
  end

  def record_induction_record_events(induction_records)
    # TODO: induction_record versions might create duplicate events in the log
    induction_records.each { |record| record_paper_trail_events(record) }
  end

  def record_participant_declaration_events(declarations)
    declarations.each do |declaration|
      description = "#{declaration.declaration_type.capitalize}Declaration.made"
      actor = declaration.cpd_lead_provider.name
      @events.push ParticipantEvent.new(@user.id, declaration.declaration_date, description, actor, nil)

      declaration.declaration_states.each do |declaration_state|
        description = "#{declaration.declaration_type.capitalize}Declaration.state"
        actor = declaration.cpd_lead_provider.name
        value = declaration_state.state

        @events.push ParticipantEvent.new(@user.id, declaration_state.created_at, description, actor, value)
      end
    end
  end

  def record_school_cohort_events(school_cohort)
    if school_cohort.versions.empty?
      record_created_event(school_cohort, school_cohort.school&.name)
    else
      record_paper_trail_events(school_cohort)
    end
  end

  def record_partnership_events(partnership)
    record_paper_trail_events(partnership)
  end

  def record_validation_events(validation_data)
    validation_data.attributes.each do |key, value|
      next unless key != "created_at" || key != "updated_at"

      description = "#{validation_data.class}.#{key}"
      actor = "Unknown"

      value = "#{key}-hidden" if %w[full_name date_of_birth nino].include?(key)

      # as we don't keep a history the data in this object can only be reliably true from the last updated field
      @events.push ParticipantEvent.new(@user.id, validation_data.updated_at, description, actor, value)
    end

    # validation_data is not auditable
  end

  def record_eligibility_events(eligibility)
    record_paper_trail_events(eligibility)
  end

  def record_validation_decision_events(decisions)
    decisions.each { |decision| record_paper_trail_events(decision) }
  end

  def record_created_event(entity, actor)
    entity.attributes&.each do |key, value|
      record_event(entity.updated_at, entity, key, value, actor)
    end
  end

  def record_paper_trail_events(entity)
    entity.versions&.each do |version|
      # TODO: if the version is of type "created" then we need to record the default values that were not overridden

      version.object_changes&.each do |key, value|
        record_event(version.created_at, entity, key, value, get_user_label(version.whodunnit))
      end
    end
  end

  def record_event(date, entity, key, value, actor)
    return if value.nil? || %w[created_at updated_at notes school_ukprn start_date end_date login_token login_token_valid_until].include?(key) || (key == "induction_status" && value == "changed")

    description = "#{entity.class}.#{key}"
    value = value.is_a?(Array) ? value[1] : value

    if key == "school_cohort_id"
      school_cohort = SchoolCohort.find_by(id: value)

      unless school_cohort.nil?
        record_school_cohort_events(school_cohort)
      end
    end

    if key == "teacher_profile_id"
      teacher_profile = TeacherProfile.find_by(id: value)

      unless teacher_profile.nil?
        record_teacher_record_events(teacher_profile)
      end
    end

    # hide PII
    value = "#{key}-hidden" if %w[full_name email date_of_birth nino].include?(key)
    value = get_cohort_label(value) if key == "cohort_id"
    value = get_schedule_label(value) if key == "schedule_id"
    value = get_lead_provider_label(value) if key == "lead_provider_id"
    value = get_delivery_partner_label(value) if key == "delivery_partner_id"
    value = get_appropriate_body_label(value) if key == "appropriate_body_id"

    if %w[induction_programme_id core_induction_programme_id default_induction_programme_id].include?(key)
      value = get_induction_programme_label(value)
    end

    @events.push ParticipantEvent.new(@user.id, date, description, actor, value)
  end

  def get_user_label(user_id)
    return "Unknown" if user_id.nil?

    user = User.find_by(id: user_id)
    return user_id if user.nil?

    parts = user.email.split("@")
    parts[1] || parts[0]
  end

  def get_lead_provider_label(lead_provider_id)
    lead_provider = LeadProvider.find_by(id: lead_provider_id)
    return lead_provider_id if lead_provider.nil?

    lead_provider.name
  end

  def get_delivery_partner_label(delivery_partner_id)
    delivery_partner = DeliveryPartner.find_by(id: delivery_partner_id)
    return delivery_partner_id if delivery_partner.nil?

    delivery_partner.name
  end

  def get_schedule_label(schedule_id)
    schedule = Finance::Schedule.find_by(id: schedule_id)
    return schedule_id if schedule.nil?

    schedule.schedule_identifier
  end

  def get_appropriate_body_label(appropriate_body_id)
    appropriate_body = AppropriateBody.find_by(id: appropriate_body_id)
    return appropriate_body_id if appropriate_body.nil?

    appropriate_body.name
  end

  def get_cohort_label(cohort_id)
    cohort = Cohort.find_by(id: cohort_id)
    return cohort_id if cohort.nil?

    cohort.academic_year
  end

  def get_induction_programme_label(induction_programme_id)
    induction_programme = InductionProgramme.find_by(id: induction_programme_id)
    return induction_programme_id if induction_programme.nil?

    "#{induction_programme.training_programme} | #{induction_programme.lead_provider.name} | #{induction_programme.delivery_partner.name} | #{induction_programme.cohort.academic_year}"
  end
end
