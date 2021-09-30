# frozen_string_literal: true

module NPQ
  class Accept
    class << self
      def call(npq_application:)
        new(npq_application: npq_application).call
      end
    end

    attr_reader :npq_application

    def initialize(npq_application:)
      @npq_application = npq_application
    end

    def call
      other_applications = NPQValidationData.where(user_id: user.id).where.not(id: npq_application.id)
      ApplicationRecord.transaction do
        teacher_profile.update!(trn: npq_application.teacher_reference_number) if npq_application.teacher_reference_number_verified?
        create_profile
        npq_application.update(lead_provider_approval_status: "accepted") && other_applications.update(lead_provider_approval_status: "rejected")
      end
    end

  private

    def create_profile
      ParticipantProfile::NPQ.create!(
        id: npq_application.id,
        schedule: Finance::Schedule.default,
        npq_course: npq_application.npq_course,
        teacher_profile: teacher_profile,
        school_urn: npq_application.school_urn,
        school_ukprn: npq_application.school_ukprn,
      ) do |participant_profile|
        ParticipantProfileState.find_or_create_by(participant_profile: participant_profile)
      end
    end

    def teacher_profile
      @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
    end

    def user
      @user ||= npq_application.user
    end
  end
end
