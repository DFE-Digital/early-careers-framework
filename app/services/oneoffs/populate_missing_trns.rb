# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs
  class PopulateMissingTrns
    include HasRecordableInformation

    def perform_change(dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        npq_teacher_profiles_without_trns.find_each do |teacher_profile|
          trns = lookup_trns(teacher_profile.user)

          record_info("multiple TRNs found for teacher profile #{teacher_profile.id} - ignoring: #{trns.join(', ')}") if trns.count > 1

          next unless trns.size == 1

          teacher_profile.update!(trn: trns.first)
          record_info("teacher profile TRN updated to #{teacher_profile.trn} for teacher profile #{teacher_profile.id}")
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def lookup_trns(user)
      trns_from_npq_applications = lookup_trns_from_npq_applications(user)

      trns_from_npq_applications
        .uniq
        .map { |trn| TeacherReferenceNumber.new(trn) }
        .select(&:valid?)
        .map(&:formatted_trn)
    end

    def lookup_trns_from_npq_applications(user)
      user
        .npq_applications
        .order(:created_at)
        .joins("LEFT JOIN teacher_profiles ON teacher_profiles.trn = npq_applications.teacher_reference_number")
        .where(teacher_reference_number_verified: true, teacher_profiles: { trn: nil })
        .pluck(:teacher_reference_number)
    end

    def npq_teacher_profiles_without_trns
      TeacherProfile
        .includes(:npq_profiles)
        .where(trn: nil)
        .where.not(npq_profiles: { id: nil })
    end
  end
end
