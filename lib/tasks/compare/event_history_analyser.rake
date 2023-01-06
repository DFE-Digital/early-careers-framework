# frozen_string_literal: true

require "json-diff"

#noinspection RubyInstanceMethodNamingConvention
class HistoryBuilder
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
    # - SchoolCohort ( changing may affect participant )
    # - InductionProgramme ( default changing for school_cohort may affect participant )
    # - Partnership ( default changing for school_cohort may affect participant )
    # - InductionCoordinatorProfile ( showing when a new SIT took over )
    # - SchoolMentors ( what schools the participant is a mentor for )

    record_user_events @user unless @user.nil?
    record_teacher_record_events @user.teacher_profile unless @user.teacher_profile.nil?

    @user.participant_identities.each { |identity| record_identity_events(identity) } unless @user.participant_identities.empty?

    unless @user.participant_profiles.empty?
      @user.participant_profiles.each do |profile|
        record_profile_events(profile)
        record_participant_declaration_events(profile.participant_declarations.sort_by(&:created_at))

        # the following are only relevant to ECF profiles
        next unless profile.ecf?

        # not all ECF Participants have induction records !!
        record_induction_record_events(profile.induction_records.oldest_first) unless profile.induction_records.empty?
        record_validation_events(profile.ecf_participant_validation_data) unless profile.ecf_participant_validation_data.nil?
        record_validation_decision_events(profile.validation_decisions) unless profile.validation_decisions.nil?
        record_eligibility_events(profile.ecf_participant_eligibility) unless profile.ecf_participant_eligibility.nil?

        # if profile.mentor?
        #   profile.school_mentors
        # end
      end
    end

    @events.sort_by!(&:date)
  end

  def self.from_participant_profile(profile)
    new(profile.user)
  end

  def self.from_user(user)
    new(user)
  end

  private

  def record_user_events(user)
    record_created_event(user, user.school&.name)
    record_paper_trail_events(user)
  end

  def record_teacher_record_events(teacher_record)
    record_created_event(teacher_record, teacher_record.school&.name)
    record_paper_trail_events(teacher_record)
  end

  def record_profile_events(participant_profile)
    record_created_event(participant_profile, participant_profile.school&.name)
    record_paper_trail_events(participant_profile)
  end

  def record_identity_events(identity)
    record_created_event(identity, nil)
  end

  def record_induction_record_events(induction_records)
    record_created_event(induction_records.first, nil)

    previous_record = nil
    induction_records.each do |record|
      record.attributes.each do |key, value|
        if previous_record.nil? || previous_record[key] != value
          if key != "created_at" && key != "updated_at" && key != "start_date" && key != "end_date" && !(key == "induction_status" && value == "changed")
            description = "#{record.class}.#{key}"
            actor = "Unknown" # TODO: papertrail created version will tell us the user

            @events.push ParticipantEvent.new(@user.id, record.start_date, description, actor, value)
          end
        end
      end

      # TODO: we need to compare the created version to the previous_record
      # record_paper_trail_events(record)

      previous_record = record
    end
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

  def record_validation_events(validation_data)
    validation_data.attributes.each do |key, value|
      if key != "created_at" || key != "updated_at"
        description = "#{validation_data.class}.#{key}"
        actor = "Unknown"
        value = "#{key}-hidden" # obfuscate the value

        @events.push ParticipantEvent.new(@user.id, validation_data.created_at, description, actor, value)
      end
    end

    # validation_data is not auditable
  end

  def record_eligibility_events(eligibility)
    record_paper_trail_events(eligibility)
  end

  def record_validation_decision_events(decisions)
    decisions.each { |decision| record_paper_trail_events(decision) }
  end

  def record_created_event(entity, actor, value = nil)
    description = "#{entity.class}.created"
    actor = actor || "Unknown"
    @events.push ParticipantEvent.new(@user.id, entity.created_at, description, actor, value)
  end

  def record_paper_trail_events(entity)
    entity.versions&.each do |version|
      version.object_changes&.each do |key, value|
        if key != "created_at" || key != "updated_at" || key != "notes" || key != "school_ukprn"
          description = "#{entity.class}.#{key}"
          actor = version.whodunnit || "Unknown"
          value = value[1]
          value = "#{key}-hidden" if key == "full_name" || key == "email"
          @events.push ParticipantEvent.new(@user.id, version.created_at, description, actor, value)
        end
      end
    end
  end
end

namespace :compare do
  namespace :event_history_analyser do
    desc "Extracts a history of events from each user in the database"

    task :run, %i[batch_size page] => :environment do |_task, args|
      args.with_defaults batch_size: '1000', page: '1'

      report_batch_size = args[:batch_size].to_i
      report_page = args[:page].to_i - 1
      report_page = 0 if report_page < 0

      folder_timestamp = Time.zone.now.strftime "%Y-%m-%d"
      folder_path = "/tmp/#{folder_timestamp}"
      unless Dir.exist? folder_path
        puts "[#{DateTime.current.strftime("%H:%M:%S")}] Creating folder #{folder_path}/"
        Dir.mkdir folder_path
      end

      ecf_participant_profiles = ParticipantProfile::ECF.order(:created_at)
                                        .limit(report_batch_size)
                                        .offset(report_page * report_batch_size)

      events = []
      ecf_participant_profiles.each do |participant_profile|
        HistoryBuilder.from_participant_profile(participant_profile).events.each { |event| events << event.to_h }
      end

      file_path = "#{folder_path}/event-history-#{args[:page]}.json"
      puts "[#{DateTime.current.strftime("%H:%M:%S")}] Writing #{events.count} events to #{file_path}"
      File.open(file_path, "w") { |r| r.puts JSON.generate(events) }
    end
  end
end
