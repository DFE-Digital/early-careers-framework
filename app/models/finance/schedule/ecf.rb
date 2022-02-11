# frozen_string_literal: true

class Finance::Schedule::ECF < Finance::Schedule
  def self.permitted_course_identifiers
    %w[ecf-induction ecf-mentor]
  end

  def self.default
    find_by(cohort: Cohort.current, schedule_identifier: "ecf-standard-september")
  end
end
