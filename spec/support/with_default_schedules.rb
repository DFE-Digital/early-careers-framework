# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    (2020..Date.current.year).each do |start_year|
      cohort = create(:cohort, start_year:)
      create(:ecf_schedule, cohort:)
      create(:npq_specialist_schedule, cohort:)
      create(:npq_leadership_schedule, cohort:)
      create(:npq_aso_schedule, cohort:)
      create(:npq_ehco_schedule, cohort:)
    end
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
