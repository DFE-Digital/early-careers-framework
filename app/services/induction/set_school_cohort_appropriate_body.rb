# frozen_string_literal: true

class Induction::SetSchoolCohortAppropriateBody < BaseService
  def call
    ActiveRecord::Base.transaction do
      id = appropriate_body_id unless appropriate_body_appointed == false
      set_induction_records_matching_school_ab(appropriate_body_id: id)
      school_cohort.update!(appropriate_body_id: id)
    end
  end

private

  attr_reader :school_cohort, :appropriate_body_id, :appropriate_body_appointed

  def initialize(school_cohort:, appropriate_body_id:, appropriate_body_appointed:)
    @school_cohort = school_cohort
    @appropriate_body_id = appropriate_body_id
    @appropriate_body_appointed = appropriate_body_appointed
  end

  def set_induction_records_matching_school_ab(appropriate_body_id:)
    school_cohort.induction_programmes
                 .map(&:participant_profiles).flatten.uniq
                 .map(&:latest_induction_record)
                 .select(&:matches_school_appropriate_body?)
                 .each do |induction_record|
      induction_record.update!(appropriate_body_id:)
    end
  end
end
