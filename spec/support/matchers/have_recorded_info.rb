# frozen_string_literal: true

RSpec::Matchers.define :have_recorded_info do |expected_info|
  match do |instance|
    Array.wrap(expected_info).each do |info|
      expect(instance.recorded_info).to include(info)
      expect(Rails.logger).to have_received(:info).with(info)
    end
  end
end
