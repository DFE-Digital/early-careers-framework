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
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course).first
    end

    def declaration_type
      ParticipantDeclaration::NPQ
    end

    def actual_lead_provider
      user_profile.validation_data.npq_lead_provider.cpd_lead_provider
    end
  end
end
