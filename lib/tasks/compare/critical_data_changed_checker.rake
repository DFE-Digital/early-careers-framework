# frozen_string_literal: true

require "json-diff"

CSV_REPORT_COLUMNS = %i[
  participant_profile_id
  records_started
  last_updated
  changed
  changed_lead_provider
  changed_delivery_partner
  changed_school
  changed_cohort
  changed_mentor
  changed_external_id
  changed_email
  changed_schedule
  registration_year
].freeze

Row = Struct.new(
  :induction_record,
  :participant_profile_id,
  :past_lead_provider_ids,
  :past_delivery_partner_ids,
  :past_school_urns,
  :past_cohort_years,
  :past_mentor_ids,
  :past_identity_ids,
  :past_emails,
  :past_schedules,
  :records_started_on,
  :last_updated_on,
  keyword_init: true,
) do

  def records_started
    records_started_on&.strftime("%Y-%m-%d")
  end

  def last_updated
    last_updated_on&.strftime("%Y-%m-%d")
  end

  def registration_year
    year = records_started_on&.year
    # schools are encouraged to begin registering from May
    year - 1 if !year.nil? && records_started_on.month < 5
    year
  end

  def changed_lead_provider
    ([induction_record&.lead_provider&.id] + past_lead_provider_ids).compact.uniq.count > 1
  end

  def changed_delivery_partner
    ([induction_record&.delivery_partner&.id] + past_delivery_partner_ids).compact.uniq.count > 1
  end

  def changed_school
    ([induction_record&.school&.urn] + past_school_urns).compact.uniq.count > 1
  end

  def changed_cohort
    ([induction_record&.cohort&.start_year] + past_cohort_years).compact.uniq.count > 1
  end

  def changed_mentor
    ([induction_record&.mentor&.id] + past_mentor_ids).compact.uniq.count > 1
  end

  def changed_external_id
    ([induction_record&.preferred_identity&.external_identifier] + past_identity_ids).compact.uniq.count > 1
  end

  def changed_email
    ([induction_record&.preferred_identity&.email] + past_emails).compact.uniq.count > 1
  end

  def changed_schedule
    ([induction_record&.schedule&.id] + past_schedules).compact.uniq.count > 1
  end

  def changed
    changed_lead_provider ||
      changed_delivery_partner ||
      changed_school ||
      changed_cohort ||
      changed_mentor ||
      changed_external_id ||
      changed_email ||
      changed_schedule
  end

  def to_h
    {
      participant_profile_id:,
      records_started:,
      last_updated:,
      changed:,
      changed_lead_provider:,
      changed_delivery_partner:,
      changed_school:,
      changed_cohort:,
      changed_mentor:,
      changed_external_id:,
      changed_email:,
      changed_schedule:,
      registration_year:,
    }
  end

  def to_csv_row
    CSV_REPORT_COLUMNS.map { |csv_column| send(csv_column) }
  end
end

namespace :compare do
  # This task is intended to loop through each open induction record and work
  # out if any _critical_ fields have changed since the specified date. The date
  # is currently hardcoded but we should probably pass that in as a param.
  #
  # The full list of participant API fields, those considered critical are marked with:
  #
  # - participant identifier *
  # - lead provider
  # - email
  # - full_name
  # - mentor
  # - school *
  # - participant type *
  # - cohort *
  # - school participant status
  # - TRN
  # - TRN validated
  # - funding eligibility
  # - lead provider training status
  # - schedule *
  # - updated date
  #
  # The results are stored in an array of Row structs which is intended to be
  # parsed into a CSV and written to disk
  namespace :critical_data_changed_checker do
    desc "Analyse critical data changes over a period"

    task :run, %i[start_date end_date] => :environment do |_task, args|
      args.with_defaults start_date: "2022-05-01", end_date: "2023-04-30"

      report_start_date = Date.parse(args[:start_date])
      report_end_date = Date.parse(args[:end_date])

      folder_timestamp = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
      folder_path = "/tmp/#{folder_timestamp}"
      puts "Creating folder #{folder_path}/"
      Dir.mkdir folder_path

      period_end_date = Date.new(report_start_date.year, report_start_date.month - 1, 1)

      while period_end_date < report_end_date
        period_start_date = period_end_date + 1.day
        period_end_date = Date.new(period_start_date.year, period_start_date.month, -1)

        file_path = "#{folder_path}/critical-data-changes-report-#{period_start_date.strftime("%Y-%m-%d")}-#{period_end_date.strftime("%Y-%m-%d")}.csv"
        rows = analyse_period(period_start_date, period_end_date)
        puts "Writing report to #{file_path}"
        create_csv_report(file_path, rows)

        changed = rows.filter(&:changed).count
        complete = rows.reject(&:changed).count

        puts "#{period_start_date.strftime("%Y-%m-%d")} to #{period_end_date.strftime("%Y-%m-%d")}"
        puts sprintf("total analysed: %i :: total changed in period: %i", complete, changed)
      end
    end

    def create_csv_report(file_path, rows)
      CSV.open(file_path, "wb") do |csv|
        csv << CSV_REPORT_COLUMNS

        rows.each do |row|
          csv << row.to_csv_row
        end
      end
    end

    def analyse_period(period_start_date, period_end_date)
      rows = []
      InductionRecord.find_in_batches.each do |batch|
        batch.each do |induction_record|
          previous_versions = InductionRecord
                                .where(participant_profile_id: induction_record.participant_profile_id)
                                .where(InductionRecord.arel_table[:updated_at].gteq(period_start_date))
                                .where(InductionRecord.arel_table[:updated_at].lteq(period_end_date))
                                .where.not(id: induction_record.id)

          row = Row.new(induction_record:, participant_profile_id: induction_record.participant_profile_id)

          participant_created_on = induction_record.participant_profile&.created_at
          first_induction_record_start_date = induction_record.participant_profile&.induction_records&.oldest&.start_date
          row.records_started_on = !participant_created_on.nil? && participant_created_on < first_induction_record_start_date ? participant_created_on : first_induction_record_start_date

          row.last_updated_on = induction_record.updated_at

          # participant identifier
          # this finds all the previous participant identities and retrieves the external identifiers
          row.past_identity_ids = previous_versions.map { |pv| pv&.preferred_identity&.external_identifier }

          # lead provider
          # this finds all the previous lead providers which indicates if the participant would have been available in the API
          row.past_lead_provider_ids = previous_versions.map { |pv| pv&.lead_provider&.id }

          # delivery partner
          # this should have no effect on the availability of the participant through the UI
          row.past_delivery_partner_ids = previous_versions.map { |pv| pv&.delivery_partner&.id }

          # email
          # this provides the ability for the Lead Provider to continue with registration
          row.past_emails = previous_versions.map { |pv| pv&.preferred_identity&.email }

          # full name
          # This has to be done through support and should trigger a re-validation of the TRN
          # a confirmation of DoB is required
          # in a case where a new TRN is identified a new User and TeacherProfile should be created

          # mentor
          # changes to mentors is a thing that happens due to leavers or reorganisation
          # mentors are also assigned later in some cases
          row.past_mentor_ids = previous_versions.map { |pv| pv&.mentor&.id }

          # school
          # a change to this would indicate a transfer of management responsibility
          row.past_school_urns = previous_versions.map { |pv| pv&.school&.urn }

          # participant type
          # a new ParticipantProfile would be the result of this so it can't be measured

          # cohort
          # lead providers use this to identify which materials are required for a participant
          # they should actually contact the school for this sort of information
          row.past_cohort_years = previous_versions.map { |pv| pv&.cohort&.start_year }

          # school status
          # indicates whether the current school has stopped managing the records for this participant

          # TRN
          # allows multiple participations to be reconciled against each other
          # fallback for outcome reporting to TRA if it does not come through the CPD APIs

          # TRN validated
          # indicates whether there is a possibility that this participant is a duplicate or incorrectly reported

          # funding eligibility
          # indicates if the school will need to fund the Induction Training themselves

          # lead provider training status
          # confirmation of the status set by the lead provider themselves

          # schedule
          # determines when milestones will be hit
          row.past_schedules = previous_versions.map { |pv| pv&.schedule&.id }

          # updated date
          # changes on sub entities are bubbled up to the ParticipantProfile
          # User <- ParticipantIdentity
          # User <- TeacherProfile
          # User <- TeacherProfile <- ParticipantProfile
          # User <- TeacherProfile <- ParticipantProfile <- InductionRecord
          # User <- TeacherProfile <- ParticipantProfile <- ECFParticipantEligibility
          # User <- TeacherProfile <- ParticipantProfile <- ECFParticipantValidationData
          # User <- TeacherProfile <- ParticipantProfile <- NPQApplication

          # paper trail entities
          # - User
          # - TeacherProfile
          # - ParticipantProfile
          # - InductionRecord
          # - InductionProgramme
          # - ECFParticipantEligibility
          # - Partnership
          # - SchoolCohort

          rows << row
        end
      end

      rows
    end
  end
end
