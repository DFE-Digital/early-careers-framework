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
    ([induction_record&.school_cohort&.cohort&.start_year] + past_cohort_years).compact.uniq.count > 1
  end

  def changed_mentor
    ([induction_record&.mentor&.id] + past_mentor_ids).compact.uniq.count > 1
  end

  def changed
    changed_lead_provider ||
      changed_delivery_partner ||
      changed_school ||
      changed_cohort ||
      changed_mentor
  end

  def to_h
    {
      participant_profile_id:,
      changed:,
      changed_lead_provider:,
      changed_delivery_partner:,
      changed_school:,
      changed_cohort:,
    }
  end
end

namespace :compare do
  # This task is intended to loop through each open induction record and work
  # out if any _critical_ fields have changed since the specified date. The date
  # is currently hardcoded but we should probably pass that in as a param.
  #
  # The fields considered critical are:
  #
  # * lead provider
  # * delivery partner
  # * school
  # * cohort
  # * induction_start_date
  # * validated trn
  # * funding eligibility
  # * external_id
  #
  # The results are stored in an array of Row structs which is intended to be
  # passed CSV and written to disk
  namespace :critical_data_changed_checker do
    desc "compare"
    task run: :environment do
      rows = []

      registration_end_date = Date.new(2022, 9, 1)
      first_declaration_date = Date.new(2022, 10, 31)

      InductionRecord.end_date_null.find_in_batches.each do |batch|
        batch.each do |induction_record|
          previous_versions = InductionRecord
                                .where(participant_profile_id: induction_record.participant_profile_id)
                                .where(InductionRecord.arel_table[:created_at].gteq(registration_end_date))
                                .where(InductionRecord.arel_table[:created_at].lteq(first_declaration_date))
                                .where.not(id: induction_record.id)

          row = Row.new(induction_record:, participant_profile_id: induction_record.participant_profile_id)

          # lead provider
          row.past_lead_provider_ids = previous_versions.map { |pv| pv&.lead_provider&.id }

          # delivery partner
          row.past_delivery_partner_ids = previous_versions.map { |pv| pv&.delivery_partner&.id }

          # school
          row.past_school_urns = previous_versions.map { |pv| pv&.school&.urn }

          # cohort
          row.past_cohort_years = previous_versions.map { |pv| pv&.school_cohort&.cohort&.start_year }

          # mentor
          row.past_mentor_ids = previous_versions.map { |pv| pv&.mentor&.id }

          # induction_start_date
          # validated trn
          # funding eligibility
          # external_id
          # participant_identity

          rows << row
        end
      end

      data = rows.map(&:to_h)

      folder_timestamp = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
      folder_path = "/tmp/#{folder_timestamp}"

      puts "writing detailed reports to folder #{folder_path}/"
      Dir.mkdir folder_path
      File.open("#{folder_path}/critical-data-changes-report.json", "w") { |r| r.puts JSON.pretty_generate(data) }

      changed = data.filter { |row| row[:changed] }.count
      complete = data.reject { |row| row[:changed] }.count
      percent = 100 - (changed.to_f / complete * 100)

      puts sprintf("total completed: %i :: total changed: %i :: percentage: %.2f%%", complete, changed, percent)
    end
  end
end
