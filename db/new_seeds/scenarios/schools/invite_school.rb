# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module School
      class InviteSchool
        attr_reader :school, :token, :path

        def initialize(school:)
          @school = school
        end

        def invite!
          InviteSchools.new.perform(Array.wrap(school.urn))

          @token = NominationEmail.find_by(school_id: school.id).token

          @path = Rails.application.routes.url_helpers.choose_how_to_continue_path(token:).tap do |p|
            Rails.logger.info("seeding nomination path for #{school.name}: #{p}")
          end

          self
        end
      end
    end
  end
end
