# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    # create cohorts since 2020 with default schedule
    end_year = Date.current.month < 9 ? Date.current.year : Date.current.year + 1
    (2020..end_year).each do |start_year|
      cohort = Cohort.find_by(start_year:) || create(:cohort, start_year:)
      Finance::Schedule::ECF.default_for(cohort:) || create(:ecf_schedule, cohort:)
    end

    # create extra schedules for the current cohort
    cohort = Cohort.current
    {
      npq_specialist_schedule: %w[npq-specialist-spring npq-specialist-autumn],
      npq_leadership_schedule: %w[npq-leadership-spring npq-leadership-autumn],
      npq_aso_schedule:        %w[npq-aso-december],
      npq_ehco_schedule:       %w[npq-ehco-november npq-ehco-december npq-ehco-march npq-ehco-june],
    }.each do |schedule_type, schedule_identifiers|
      schedule_identifiers.each do |schedule_identifier|
        Finance::Schedule.find_by(cohort:, schedule_identifier:) || create(schedule_type, cohort:, schedule_identifier:)
      end
    end
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
