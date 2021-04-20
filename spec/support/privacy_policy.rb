# frozen_string_literal: true

RSpec.configure do |rspec|
  rspec.before(:suite) do
    FactoryBot.create(:privacy_policy, major_version: 0, minor_version: 1) unless PrivacyPolicy.current
  end
end
