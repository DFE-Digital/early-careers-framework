# frozen_string_literal: true

# ActiveJob is foricing test adapter regardless of queue configuration.
# See: https://github.com/rails/rails/issues/37270
RSpec.configure do |rspec|
  rspec.before do
    (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
  end
end
