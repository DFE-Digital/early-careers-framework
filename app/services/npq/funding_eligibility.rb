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

    def all_npq_courses
      npq_course.rebranded_alternative_courses
    end

    def users
      User.where(teacher_profile: teacher_profiles)
    end

    def teacher_profiles
      @teacher_profiles ||= TeacherProfile.where(trn: trn)
    end

    def previously_funded?
      users.flat_map.any? do |user|
        user.npq_applications
        .where(npq_course: all_npq_courses)
        .where(eligible_for_funding: true)
        .accepted
        .any?
      end
    end
  end
end
