# frozen_string_literal: true

module Oneoffs::NPQ
  class BackfillTrnToTeacherProfile
    def migrate
      # locate all TeacherProfiles with empty TRN
      teacher_profiles_without_trns.in_batches.each_record do |profile|
        trns = profile.user.npq_applications.map(&:teacher_reference_number).uniq
        # check if they are correct
        if trns.count == 1 && TeacherReferenceNumber.new(trns.first).valid?
          profile.trn = trns.first
          profile.save!
        end
      end
    end

  private

    def teacher_profiles_without_trns
      TeacherProfile.where(trn: nil)
    end
  end
end
