# frozen_string_literal: true

require "active_support/testing/time_helpers"

module ValidTestDataGenerators
  class BasePopulater
    include ActiveSupport::Testing::TimeHelpers

    class << self
      def populate(name:, total_schools: 10, participants_per_school: 10, cohort: Cohort.current, number_of_participants: 100)
        new(name:, total_schools:, participants_per_school:, cohort:, number_of_participants:).populate
      end
    end

    def populate
      raise "Not implemented"
    end

  private

    attr_reader :lead_provider, :total_schools, :participants_per_school, :cohort, :number_of_participants, :logger

    def create_user!
      name = Faker::Name.name
      User.create!(full_name: name, email: Faker::Internet.email(name:))
    end
  end
end
