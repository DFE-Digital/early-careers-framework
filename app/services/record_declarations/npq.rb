# frozen_string_literal: true

module RecordDeclarations
  module NPQ
    extend ActiveSupport::Concern

    included do
      delegate :npq?, :npq_profiles, to: :user
    end

    def participant?
      npq?
    end

    def user_profile
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course_identifier).first
    end

    def declaration_model
      ParticipantDeclaration::NPQ
    end

    def actual_lead_provider
      user_profile.validation_data.npq_lead_provider.cpd_lead_provider
    end

    def valid_declaration_types
      %w[started completed retained-1 retained-2]
    end
  end
end
