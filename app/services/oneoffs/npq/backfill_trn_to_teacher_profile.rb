# frozen_string_literal: true

module Oneoffs::NPQ
  class BackfillTrnToTeacherProfile
    def migrate
      # locate all TeacherProfiles with empty TRN
      incorrect_teacher_profiles.in_batches.each_record do |profile|
        trns = profile.user.npq_applications.map(&:teacher_reference_number).uniq
        # check if they are correct
        if trns.count == 1 && trns.first.length == 7
          profile.trn = trns.first
          profile.save!
        end
      end
    end

  private

    def incorrect_teacher_profiles
      TeacherProfile.where(trn: nil)
    end
  end
end
