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

  desc "Generate a CSV with the Participant's and DQT's appropriate body missmatches"
  task export_mismatches: :environment do
    csv_file_path = Rails.root.join("tmp/mismatched_records.csv")

    CSV.open(csv_file_path, "w", headers: true) do |csv|
      csv << ["TRN", "Appropriate Body Name", "DQT Appropriate Body Name"]

      ParticipantAppropriateBodyDQTCheck.includes(:participant_profile).find_each do |record|
        if record.normalised_appropriate_body_name != record.dqt_appropriate_body_name
          csv << [record.participant_profile.trn, record.normalised_appropriate_body_name, record.dqt_appropriate_body_name]
        end
      end
    end

    puts "CSV file with mismatched records generated at #{csv_file_path}"
  end
end
