# frozen_string_literal: true

class PupilPremium < ApplicationRecord
  THRESHOLD_PERCENTAGE = 40

  belongs_to :school

  def uplift?
    percentage_eligible >= THRESHOLD_PERCENTAGE
  end

  scope :with_pupils, -> { where(arel_table[:total_pupils].gt(0)) }
  scope :with_start_year, ->(start_year) { where(start_year:) }
  scope :only_with_uplift, ->(start_year) { with_pupils.merge(with_start_year(start_year)).merge(exceeding_percentage) }

  def self.exceeding_percentage(threshold: THRESHOLD_PERCENTAGE)
    eligible_pupils = Arel::Nodes::NamedFunction.new("CAST", [arel_table[:eligible_pupils].as("FLOAT")])
    total_pupils = arel_table[:total_pupils]

    where(
      Arel::Nodes::Multiplication.new(
        Arel::Nodes::Division.new(eligible_pupils, total_pupils),
        100,
      ).gteq(threshold),
    )
  end

private

  def percentage_eligible
    (eligible_pupils.to_f / total_pupils) * 100
  end
end
