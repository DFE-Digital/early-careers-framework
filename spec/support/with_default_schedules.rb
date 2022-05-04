# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  let!(:ecf_schedule)            { create(:ecf_schedule) }
  let!(:npq_specialist_schedule) { create(:npq_specialist_schedule) }
  let!(:npq_leadership_schedule) { create(:npq_leadership_schedule) }
  let!(:npq_aso_schedule)        { create(:npq_aso_schedule) }
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
