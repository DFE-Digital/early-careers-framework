# frozen_string_literal: true

RSpec.shared_context "with default schedules", shared_context: :metadata do
  before do
    create(:schedule, :npq_specialist)
    create(:schedule, :npq_leadership)
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_default_schedules
end
