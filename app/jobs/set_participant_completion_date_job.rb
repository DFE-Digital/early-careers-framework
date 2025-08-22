# frozen_string_literal: true

# This is a job to update all of the induction completion dates from DQT for
# all of the 2021/2022 ECTs that do not currently have them.
# (see BuildCompletionCandidatesListJob for how the list is populated)
# It runs in batches of 200 as we have a 300 lookup per minute limit on the API
# This could get adapted later to be a regular running process with a bit more logic
class SetParticipantCompletionDateJob < ApplicationJob
  MAX_CANDIDATES = 2000

  def perform
    candidates.each do |candidate|
      participant_profile = candidate.participant_profile
      Participants::CheckAndSetCompletionDate.call(participant_profile:,
                                                   riab_teacher: riab_teachers[participant_profile.trn])
      candidate.destroy!
    end
  rescue StandardError => e
    Rails.logger.error("SetParticipantCompletionDateJob: #{e.message}")
  end

private

  def candidates
    @candidates ||= CompletionCandidate
                      .includes(participant_profile: :teacher_profile)
                      .order(:participant_profile_id)
                      .limit(MAX_CANDIDATES)
                      .to_a
  end

  def riab_teachers
    @riab_teachers ||= RIAB::Teacher.includes(:first_induction_period, :last_induction_period)
                                    .where(trn: candidates.map(&:participant_profile).map(&:trn))
                                    .index_by(&:trn)
  end
end
