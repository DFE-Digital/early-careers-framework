# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    (2020..Date.current.year).each do |start_year|
      cohort = Cohort.find_by_start_year(start_year) || create(:cohort, start_year:)
      Finance::Schedule::ECF.default_for(cohort:) || create(:ecf_schedule, cohort:)
    end

    cohort_2021 = Cohort.find_by_start_year(2021)
    Finance::Schedule.find_by(cohort: cohort_2021, schedule_identifier: "npq-specialist-spring") ||
      create(:npq_specialist_schedule, cohort: cohort_2021)
    Finance::Schedule.find_by(cohort: cohort_2021, schedule_identifier: "npq-leadership-spring") ||
      create(:npq_leadership_schedule, cohort: cohort_2021)
    Finance::Schedule.find_by(cohort: cohort_2021, schedule_identifier: "npq-aso-december") ||
      create(:npq_aso_schedule, cohort: cohort_2021)
    Finance::Schedule.find_by(cohort: cohort_2021, schedule_identifier: "npq-ehco-december") ||
      create(:npq_ehco_schedule, cohort: cohort_2021)
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
