# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs
  class PopulateMissingTrns
    include HasRecordableInformation

    def perform_change(dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        teacher_profiles_without_trns.find_each do |teacher_profile|
          trns = lookup_trns(teacher_profile)
          next if trns.empty?

          teacher_profile.update!(trn: trns.first)

          record_info("teacher profile TRN updated to #{teacher_profile.trn} for teacher profile #{teacher_profile.id}")
          record_info("multiple TRNs found for teacher profile #{teacher_profile.id}: #{trns.join}") if trns.count > 1
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def lookup_trns(teacher_profile)
      users = associated_users(teacher_profile.user_id)

      trns_from_npq_applications = lookup_trns_from_npq_appliations(users)
      trns_from_ecf_validation = lookup_trns_from_ecf_validation(users)
      trns_from_teacher_profiles = lookup_trns_from_teacher_profiles(users)

      (trns_from_npq_applications + trns_from_ecf_validation + trns_from_teacher_profiles).uniq.select do |trn|
        TeacherReferenceNumber.new(trn).valid?
      end
    end

    def lookup_trns_from_npq_appliations(users)
      users.map { |user|
        user
          .npq_applications
          .where(teacher_reference_number_verified: true)
          .pluck(:teacher_reference_number)
      }.flatten
    end

    def lookup_trns_from_ecf_validation(users)
      participant_profiles = users.map(&:participant_profiles).flatten

      participant_profiles.map { |participant_profile|
        participant_profile.ecf_participant_validation_data&.trn
      }.flatten
    end

    def lookup_trns_from_teacher_profiles(users)
      users.map { |user| user.teacher_profile&.trn }
    end

    def associated_users(user_id)
      associated_user_ids = ParticipantIdChange
        .where(from_participant_id: user_id).or(ParticipantIdChange.where(to_participant_id: user_id))
        .pluck(:from_participant_id, :to_participant_id)
        .flatten
        .append(user_id)
        .uniq
      User.where(id: associated_user_ids)
    end

    def teacher_profiles_without_trns
      TeacherProfile.where(trn: nil)
    end
  end
end
