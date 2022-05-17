# frozen_string_literal: true

module NPQ
  class FundingEligibility
    attr_reader :trn, :npq_course_identifier

    def initialize(trn:, npq_course_identifier:)
      @trn = trn
      @npq_course_identifier = npq_course_identifier
    end

    def call
      {
        previously_funded: previously_funded?,
      }
    end

  private

    def npq_course
      @npq_course ||= NPQCourse.find_by!(identifier: npq_course_identifier)
    end

    def user
      teacher_profile.user if teacher_profile
    end

    def teacher_profile
      @teacher_profile ||= TeacherProfile.find_by(trn: trn)
    end

    def previously_funded?
      return false unless user

      user
        .npq_applications
        .where(npq_course: npq_course)
        .where(eligible_for_funding: true)
        .accepted
        .any?
    end
  end
end
