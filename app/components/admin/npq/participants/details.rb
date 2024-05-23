# frozen_string_literal: true

module Admin
  module NPQ
    module Participants
      class Details < BaseComponent
        attr_reader :profile, :user, :npq_application, :school

        def initialize(profile:, user:, npq_application:, school:)
          @profile         = profile
          @user            = user
          @npq_application = npq_application
          @school          = school
        end

        delegate :pending?, to: :profile, prefix: true

        delegate :full_name, :email, to: :user, prefix: true

        delegate :urn, :name, to: :school, prefix: true, allow_nil: true

        delegate :teacher_reference_number,
                 :nino,
                 :date_of_birth,
                 :course_name,
                 to: :npq_application,
                 prefix: true,
                 allow_nil: true

        def last_updated
          [profile.updated_at, user.updated_at, npq_application.updated_at]
            .compact
            &.max
            &.to_formatted_s(:govuk)
        end

        def funded_place
          return "" if npq_application.funded_place.nil?

          npq_application.funded_place ? "Yes" : "No"
        end
      end
    end
  end
end
