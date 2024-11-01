# frozen_string_literal: true

require "csv"

namespace :participant_appropriate_body_dqt_checks do
  desc "Pre-populate the participant_appropriate_body_dqt_checks with all the active 2024 ECT participants"
  task prepopulate_records: :environment do
    cohort_start_year = 2024

    InductionRecord
      .includes(:appropriate_body)
      .joins(:cohort, :participant_profile)
      .where(participant_profiles: { type: "ParticipantProfile::ECT" })
      .where(cohorts: { start_year: cohort_start_year })
      .where(end_date: nil, induction_status: :active, training_status: :active)
      .find_each(batch_size: 1000) do |induction_record|
      unless ParticipantAppropriateBodyDQTCheck.exists?(participant_profile_id: induction_record.participant_profile_id)
        ParticipantAppropriateBodyDQTCheck.create!(
          participant_profile_id: induction_record.participant_profile_id,
          appropriate_body_name: induction_record.appropriate_body_name,
        )
      end
    end
  end

  desc "Update the ParticipantAppropriateBodyDQTCheck records with the AB name from DQT"
  task process_records: :environment do
    batch_size = 300
    delay_interval = 1.minute

    # Limit processing to a maximum of 300 records per minute to ensure we stay within the DQT API’s 1000 requests per minute rate limit
    ParticipantAppropriateBodyDQTCheck.where(dqt_appropriate_body_name: nil).find_in_batches(batch_size:).with_index do |batch, index|
      batch.each do |record|
        UpdateParticipantAppropriateBodyDQTCheckJob.set(wait: index * delay_interval).perform_later(record.participant_profile_id)
      end
    end
  end

  # DQT records provide the AB names in a different format than what is stored in ECF.
  # To enable accurate comparison, a CSV file is required that maps all DQT AB names
  # to their corresponding ECF AB records.
  desc "Generate a CSV with the Participant's and DQT's appropriate body mismatches"
  task :export_mismatches, [:path_to_mappings_csv] => :environment do |_task, args|
    raise ArgumentError, "Please provide the path to the mappings CSV" unless args.path_to_mappings_csv

    ab_mappings = load_ab_mappings(args.path_to_mappings_csv)
    results_csv_file_path = "tmp/mismatched_records.csv"

    generate_mismatches_csv(results_csv_file_path, ab_mappings)
  end
end

# Helper method to load appropriate body mappings from the CSV
def load_ab_mappings(path_to_csv)
  ab_mappings = {}
  CSV.foreach(path_to_csv, headers: true) do |row|
    unless row.headers.include?("DQT AB name") && row.headers.include?("CPD ID")
      raise "CSV is missing required headers: 'DQT AB name' and 'CPD ID'"
    end

    ab_mappings[row["DQT AB name"]] = row["CPD ID"]
  end
  ab_mappings
end

# Helper method to generate the mismatches CSV
def generate_mismatches_csv(file_path, ab_mappings)
  CSV.open(file_path, "w", headers: true) do |csv|
    csv << ["Participant Profile ID", "Participant TRN", "ECF AB ID", "ECF AB Name", "CPD ID (from mappings CSV)", "DQT AB Name"]

    ParticipantAppropriateBodyDQTCheck.includes(:participant_profile).find_each do |record|
      ecf_ab = AppropriateBody.find_by(name: record.appropriate_body_name)
      csv_mapped_id = ab_mappings[record.dqt_appropriate_body_name] || "not found in the mappings CSV"

      # Exclude records whose DQT Induction Status is not InProgress.
      next if record.dqt_induction_status != "InProgress"

      # Add record to CSV if there is a mismatch
      if csv_mapped_id != ecf_ab&.id
        csv << [
          record.participant_profile_id,
          record.participant_profile&.trn,
          ecf_ab&.id,
          ecf_ab&.name,
          csv_mapped_id,
          record.dqt_appropriate_body_name,
        ]
      end
    end
  end
end
