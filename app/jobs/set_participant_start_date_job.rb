# frozen_string_literal: true

# This is a one off job to update all of the induction start dates from DQT for
# all of the 2021/2022 ECTs that do not currently have them.
# It runs in batches of 200 as we have a 300 lookup per minute limit on the API
# There are approx 57600 participants in this state currently
class SetParticipantStartDateJob < ApplicationJob
  def perform
    ParticipantProfile::ECT
      .eligible_status
      .joins(:teacher_profile)
      .includes(:teacher_profile)
      .where.not(teacher_profile: { trn: nil })
      .where(induction_start_date: nil)
      .where(created_at: ...Cohort.find_by(start_year: 2023).registration_start_date)
      .order(:updated_at)
      .limit(200)
      .each do |participant_profile|
        induction = DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
        next if induction.blank?

        start_date = induction["startDate"]

        # prevent touches from cascading up to User and being exposed in the API
        User.no_touching do
          # for pre-2023 registrations this should just set the induction_start_date for us
          Participants::SyncDQTInductionStartDate.call(start_date, participant_profile)
          
          # put at the bottom of the list for the next iteration if nothing changed
          participant_profile.touch
        end
      end
  rescue StandardError => e
    Rails.logger.error("SetParticipantStartDateJob: #{e.message}")
  end
end
