# frozen_string_literal: true

# Given a list of participant ids, a source year and a target year,
# move the participants from the cohort starting the source year to the one
# starting the target year.
# Meant to be run after SITs enroll participants in the wrong school cohort:
#
#   participant_profile_ids = %w[id_1 id_2 id_3 id_4]
#   Induction::AmendParticipantsCohort.call(*participant_profile_ids,
#                                           source_cohort_start_year: 2021,
#                                           target_cohort_start_year: 2022)
#
#   Returns a hash like this:
#     {
#       success: [id_1, id_3],
#       fail: {
#         id_2 => "Error after processing id_2",
#         id_4 => "Error after processing id_4",
#       }
#     }
class Induction::AmendParticipantsCohort < BaseService
  attr_reader :participant_profile_ids, :participant_profiles, :result, :source_cohort_start_year, :target_cohort_start_year

  def call
    process_participants
    result
  end

private

  def initialize(*participant_profile_ids, source_cohort_start_year:, target_cohort_start_year:)
    @participant_profile_ids = participant_profile_ids
    @participant_profiles = ParticipantProfile.where(id: participant_profile_ids).to_a
    @source_cohort_start_year = source_cohort_start_year
    @target_cohort_start_year = target_cohort_start_year
  end

  def failed(participant_profile_id:, error:)
    result[:fail].merge!(participant_profile_id => { error.attribute => error.message })
  end

  def process_participants
    setup
    participant_profile_ids.each do |participant_profile_id|
      participant_profile = participant_profiles.detect { |pp| pp.id == participant_profile_id }
      form = Induction::AmendParticipantCohort.new(participant_profile:, source_cohort_start_year:, target_cohort_start_year:)
      form.save ? success(participant_profile_id) : failed(participant_profile_id:, error: form.errors.first)
    end
  end

  def setup
    @result = { success: [], fail: {} }
  end

  def success(participant_profile_id)
    result[:success] << participant_profile_id
  end
end
