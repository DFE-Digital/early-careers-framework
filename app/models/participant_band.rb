# frozen_string_literal: true

class ParticipantBand < ApplicationRecord
  belongs_to :call_off_contract

  def number_of_participants_in_this_band(total_number_of_participants)
    smaller_than_lower_boundary(total_number_of_participants) ||
      between_boundaries(total_number_of_participants) ||
      upper_boundary - lower_boundary
  end

private

  def smaller_than_lower_boundary(total_number_of_participants)
    0 if total_number_of_participants < lower_boundary
  end

  def between_boundaries(total_number_of_participants)
    total_number_of_participants - lower_boundary if upper_boundary.nil? || (lower_boundary..upper_boundary).include?(total_number_of_participants)
  end

  def lower_boundary
    min.to_i.positive? && min - 1 || 0
  end

  def upper_boundary
    max
  end
end
