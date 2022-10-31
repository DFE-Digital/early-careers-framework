# frozen_string_literal: true

module NPQ
  class AcceptApplication
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application

    validates :npq_application, presence: { message: I18n.t("npq_application.missing_npq_application") }
    validate :not_already_accepted
    validate :cannot_change_from_rejected
    validate :other_accepted_applications_with_same_course?

    def call
      return self unless valid?

      ApplicationRecord.transaction do
        teacher_profile.update!(trn: npq_application.teacher_reference_number) if npq_application.teacher_reference_number_verified?
        create_participant_profile!
        npq_application.update(lead_provider_approval_status: "accepted") && other_applications_in_same_cohort.update(lead_provider_approval_status: "rejected")
        deduplicate_by_trn!
      end

      npq_application
    end

  private

    def not_already_accepted
      return if npq_application.blank?

      errors.add(:npq_application, I18n.t("npq_application.has_already_been_accepted")) if npq_application.accepted?
    end

    def cannot_change_from_rejected
      return if npq_application.blank?

      errors.add(:npq_application, I18n.t("npq_application.cannot_change_from_rejected")) if npq_application.rejected?
    end

    def cohort
      npq_application.cohort
    end

    def other_accepted_applications_with_same_course?
      errors.add(:npq_application, I18n.t("npq_application.has_another_accepted_application")) if other_accepted_applications_with_same_course.present?
    end

    def other_accepted_applications_with_same_course
      return if npq_application.blank?

      @other_accepted_applications_with_same_course ||= NPQApplication
                                                          .joins(:participant_identity)
                                                          .where(participant_identity: { user_id: user.id })
                                                          .where(npq_course: npq_course.rebranded_alternative_courses)
                                                          .where(lead_provider_approval_status: "accepted")
                                                          .where.not(id: npq_application.id)
    end

    def other_applications_in_same_cohort
      @other_applications_in_same_cohort ||= NPQApplication
        .joins(:participant_identity)
        .where(participant_identity: { user_id: user.id })
        .where(npq_course:)
        .where(cohort:)
        .where.not(id: npq_application.id)
    end

    def create_participant_profile!
      ParticipantProfile::NPQ.create!(
        id: npq_application.id,
        schedule: NPQCourse.schedule_for(npq_course: npq_application.npq_course, cohort:),
        npq_course: npq_application.npq_course,
        teacher_profile:,
        school_urn: npq_application.school_urn,
        school_ukprn: npq_application.school_ukprn,
        participant_identity: npq_application.participant_identity,
      ).tap do |pp|
        ParticipantProfileState.find_or_create_by(participant_profile: pp)
      end
    end

    def participant_profile
      @participant_profile ||= ParticipantProfile.find(npq_application.id)
    end

    def teacher_profile
      @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
    end

    def user
      @user ||= npq_application.participant_identity.user
    end

    def npq_course
      npq_application.npq_course
    end

    def deduplicate_by_trn!
      return if participant_profile.teacher_profile.trn.blank?

      same_trn_user = TeacherProfile
        .where(trn: participant_profile.teacher_profile.trn)
        .where.not(id: participant_profile.teacher_profile.id)
        .first
        &.user

      Identity::Transfer.call(from_user: participant_profile.user, to_user: same_trn_user) if same_trn_user
    end
  end
end
