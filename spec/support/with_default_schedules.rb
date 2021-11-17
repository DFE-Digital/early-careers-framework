# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    byebug
    create(:ecf_schedule)
    create(:npq_specialist_schedule)
    create(:npq_leadership_schedule)
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
