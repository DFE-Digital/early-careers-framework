# frozen_string_literal: true

# This is a one off job to update all of the induction completion dates from DQT for
# all of the 2021/2022 ECTs that do not currently have them.
# It runs in batches of 200 as we have a 300 lookup per minute limit on the API
# This could get adapted later to be a regular running process with a bit more logic
class SetParticipantCompletionDateJob < ApplicationJob
  def perform
    ParticipantProfile::ECT
      .eligible_status
      .joins(:teacher_profile)
      .includes(:teacher_profile)
      .where.not(teacher_profile: { trn: nil })
      .where.not(induction_start_date: nil)
      .where(created_at: ...Cohort.find_by(start_year: 2023).registration_start_date)
      .order(:updated_at)
      .limit(200)
      .each do |participant_profile|
        induction = DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)

        # prevent touches from cascading up to User and being exposed in the API
        User.no_touching do
          if induction.blank?
            participant_profile.touch
            next
          end

          completion_date = induction["endDate"]

          Induction::Complete.call(participant_profile:, completion_date:) if completion_date.present?

          # put at the bottom of the list for the next iteration if nothing changed
          participant_profile.touch
        end
      end
  rescue StandardError => e
    Rails.logger.error("SetParticipantCompletionDateJob: #{e.message}")
  end
end
