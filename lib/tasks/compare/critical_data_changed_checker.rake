# frozen_string_literal: true

require "json-diff"

Row = Struct.new(
  :induction_record,
  :participant_profile_id,
  :past_lead_provider_ids,
  :past_delivery_partner_ids,
  :past_school_urns,
  :past_cohort_years,
  :past_mentor_ids,
  :past_identity_ids,
  :past_schedules,
  keyword_init: true,
) do
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

  def changed_identity
    ([induction_record&.preferred_identity&.external_identifier] + past_identity_ids).compact.uniq.count > 1
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
      changed_identity ||
      changed_schedule
  end

  def to_h
    {
      participant_profile_id:,
      changed:,
      changed_lead_provider:,
      changed_delivery_partner:,
      changed_school:,
      changed_cohort:,
      changed_identity:,
      changed_schedule:,
    }
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
    desc "compare"
    task :run, %i[registration_start_date registration_end_date first_declaration_date] => :environment do |_task, args|
      args.with_defaults(
        registration_start_date: Date.new(2022, 7, 1),
        registration_end_date: Date.new(2022, 9, 1),
        first_declaration_date: Date.new(2022, 10, 31),
      )

      CSV_EXPORT_COLUMNS = %i[
        participant_profile_id
        changed
        changed_lead_provider
        changed_delivery_partner
        changed_school
        changed_cohort
        changed_identity
        changed_schedule
      ].freeze

      rows = []
      InductionRecord.end_date_null.find_in_batches.each do |batch|
        batch.each do |induction_record|
          previous_versions = InductionRecord
                                .where(participant_profile_id: induction_record.participant_profile_id)
                                # records were created after july 1st
                                .where(InductionRecord.arel_table[:created_at].gteq(args[:registration_start_date]))
                                # records were modified between the registration period ending and the milestone period beginning
                                .where(InductionRecord.arel_table[:updated_at].gteq(args[:registration_end_date]))
                                .where(InductionRecord.arel_table[:updated_at].lteq(args[:first_declaration_date]))
                                .where.not(id: induction_record.id)

          row = Row.new(induction_record:, participant_profile_id: induction_record.participant_profile_id)

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
          # a new ParticipantProfile would be the result of this and therefore
          #     the first InductionRecord will have be created in the period

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

      folder_timestamp = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
      folder_path = "/tmp/#{folder_timestamp}"

      puts "writing detailed reports to folder #{folder_path}/"
      Dir.mkdir folder_path

      CSV.open("#{folder_path}/critical-data-changes-report.csv", "wb") do |csv|
        csv << CSV_EXPORT_COLUMNS

        rows.each do |row|
          csv_row_data = CSV_EXPORT_COLUMNS.map { |csv_column| row.send(csv_column) }

          csv << csv_row_data
        end
      end

      changed = rows.filter(&:changed).count
      complete = rows.reject(&:changed).count
      percent = 100 - (changed.to_f / complete * 100)

      puts sprintf("total completed: %i :: total changed: %i :: percentage: %.2f%%", complete, changed, percent)
    end
  end
end
