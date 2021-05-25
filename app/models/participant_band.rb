# frozen_string_literal: true

# == Schema Info
# Table name: participant_bands
#
# call_off_contract :uuid null: false, foreign_key: true, type: :uuid
# min :integer
# max :integer
# per_participant :decimal
# timestamps

WORLD_POPULATION = 8_000_000_000 # in 2023
POTENTIAL_GLOBAL_PARTICIPANTS = WORLD_POPULATION / 25 # Based on 2% teachers * 2

class ParticipantBand < ApplicationRecord
  belongs_to :call_off_contract

  def number_in_range(total_number_of_participants)
    [distance_from_bottom_of_range(total_number_of_participants), 0].max
  end

private

  def distance_from_bottom_of_range(total_number_of_participants)
    [total_number_of_participants, upper_boundary].min - lower_boundary
  end

  def lower_boundary
    min && min - 1 || 0
  end

  # Fairly safe assumption ahead....
  # World population predicted to hit around 8_000_000_000 in 2023, so should be enough for a while
  # as there are currently only 548k teachers in the UK, which would be a maximum of around 1_000_000 participants,
  # if none of the mentors were actually teachers.
  # Revisit if the UK GOV system becomes the dominant universal standard.
  def upper_boundary
    max || POTENTIAL_GLOBAL_PARTICIPANTS
  end
end
