# frozen_string_literal: true

class ParticipantBand < ApplicationRecord
  belongs_to :call_off_contract
  delegate :set_up_fee, :recruitment_target, to: :call_off_contract

  scope :min_nulls_first, -> { order("min asc nulls first") }

  # Example:
  #
  #  0             2000          4000
  #  |              |             |
  #  |    Band A    |   Band B    |   Band C
  #  | ---------------|
  #             2100 previous participants
  #                    -------------|
  #             2000 current participants
  #
  # result is:
  # 0 current participants in Band A
  # 1900 current participants in Band B
  # 100 current participants in Band C

  def number_of_participants_in_this_band(total_current_participants, total_previous_participants = 0)
    combined_total = total_current_participants + total_previous_participants

    total_taken_by_previous_participants =
      if smaller_than_lower_boundary(total_previous_participants)
        0
      elsif upper_boundary.nil? || between_boundaries(total_previous_participants)
        total_previous_participants - lower_boundary
      else
        (upper_boundary - lower_boundary)
      end

    if smaller_than_lower_boundary(combined_total)
      0
    elsif upper_boundary.nil? || between_boundaries(combined_total)
      (combined_total - lower_boundary) - total_taken_by_previous_participants
    else
      (upper_boundary - lower_boundary) - total_taken_by_previous_participants
    end
  end

  def contract_value
    number_of_participants_in_this_band(recruitment_target) * per_participant
  end

  def output_payment_per_participant
    (per_participant * output_payment_percantage) / 100
  end

  def service_fee_total
    number_of_participants_in_this_band(recruitment_target) * service_fee_per_participant
  end

  def service_fee_per_participant
    (per_participant * service_fee_percentage) / 100 - set_up_cost_per_participant
  end

  def set_up_cost_per_participant
    lower_boundary.zero? ? set_up_fee / upper_boundary : 0
  end

private

  def smaller_than_lower_boundary(total_number_of_participants)
    total_number_of_participants < lower_boundary
  end

  def between_boundaries(number_of_participants)
    (lower_boundary..upper_boundary).include?(number_of_participants)
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
