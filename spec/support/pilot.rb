# frozen_string_literal: true

module PilotRSpec
  # Include the object (school usually) into the pilot
  def pilot!(object)
    FeatureFlag.activate(:cohortless_dashboard, for: object)
  end
end

RSpec.configure do |rspec|
  rspec.include PilotRSpec
end
