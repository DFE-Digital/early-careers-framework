# frozen_string_literal: true

class ParticipantBand < ApplicationRecord
  belongs_to :call_off_contract

  def number_of_participants_in_this_band(total_number_of_participants)
    if smaller_than_lower_boundary(total_number_of_participants)
      0
    elsif upper_boundary.nil? || between_boundaries(total_number_of_participants)
      total_number_of_participants - lower_boundary
    else
      upper_boundary - lower_boundary
    end
  end

private

  def smaller_than_lower_boundary(total_number_of_participants)
    total_number_of_participants < lower_boundary
  end

  def between_boundaries(total_number_of_participants)
    (lower_boundary..upper_boundary).include?(total_number_of_participants)
  end

  # This conversion is required because the range is specified without overlaps and starts from 0..x
  # but then goes from x+1..y, y+1..z which is clear for layout but not so good for computational calculation.
  def lower_boundary
    [min.to_i - 1, 0].max
  end

  def upper_boundary
    max
  end
end
