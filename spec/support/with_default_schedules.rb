# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    # create cohorts since 2020 with default schedule
    (2020..Date.current.year).each do |start_year|
      cohort = Cohort.find_by_start_year(start_year) || create(:cohort, start_year:)
      Finance::Schedule::ECF.default_for(cohort:) || create(:ecf_schedule, cohort:)
    end

    # create other schedules for the current cohort
    current_cohort = Cohort.current
    Finance::Schedule.find_by(cohort: current_cohort, schedule_identifier: "npq-specialist-spring") ||
      create(:npq_specialist_schedule, cohort: current_cohort)
    Finance::Schedule.find_by(cohort: current_cohort, schedule_identifier: "npq-leadership-spring") ||
      create(:npq_leadership_schedule, cohort: current_cohort)
    Finance::Schedule.find_by(cohort: current_cohort, schedule_identifier: "npq-aso-december") ||
      create(:npq_aso_schedule, cohort: current_cohort)
    Finance::Schedule.find_by(cohort: current_cohort, schedule_identifier: "npq-ehco-december") ||
      create(:npq_ehco_schedule, cohort: current_cohort)
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
