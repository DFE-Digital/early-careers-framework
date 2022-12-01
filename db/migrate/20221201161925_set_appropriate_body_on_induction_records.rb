# frozen_string_literal: true

# Sets the appropriate_body_id of latest_induction_records to that of their school_cohort if it is not already set.
class SetAppropriateBodyOnInductionRecords < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      SchoolCohort.joins(induction_programmes: { induction_records: :participant_profile })
                  .where.not(appropriate_body_id: nil)
                  .find_each do |school_cohort|
        induction_records_with_no_ab = school_cohort.induction_programmes
                                                    .map(&:participant_profile).flatten.uniq
                                                    .map(&:latest_induction_record)
                                                    .select { |ir| ir.appropriate_body_id.nil? }
        induction_records_with_no_ab.each do |ir|
          ir.update!(appropriate_body_id: school_cohort.appropriate_body_id)
        end
      end
    end
  end

  def down
    safety_assured do
      SchoolCohort.joins(induction_programmes: { induction_records: :participant_profile })
                  .find_each do |school_cohort|
        induction_records_matching_school_ab = school_cohort.induction_programmes
                                                    .map(&:participant_profile).flatten.uniq
                                                    .map(&:latest_induction_record)
                                                    .select do |ir|
          ir.appropriate_body_id == school_cohort.appropriate_body_id
        end
        induction_records_matching_school_ab.each do |ir|
          ir.update!(appropriate_body_id: nil)
        end
      end
    end
  end
end
