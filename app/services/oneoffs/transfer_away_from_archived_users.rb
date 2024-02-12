# frozen_string_literal: true

module Oneoffs
  class TransferAwayFromArchivedUsers
    include HasRecordableInformation

    def perform_change(dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        archived_users_with_participant_profiles.each do |archived_user|
          transfer_archived_user_on_teacher_profile(archived_user.teacher_profile)
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def transfer_archived_user_on_teacher_profile(teacher_profile)
      primary_user = primary_user_for_trn(teacher_profile.trn)

      return record_info("teacher profile #{teacher_profile.id} does not have a trn") unless teacher_profile.trn
      return record_info("primary user not found for trn #{teacher_profile.trn}") unless primary_user

      # Transfer the archived user teacher profile to the primary.
      Identity::Transfer.call(from_user: teacher_profile.user, to_user: primary_user)

      # The TRN should have been cleared during the initial archiving of the user.
      teacher_profile.update!(trn: nil)

      record_info("Transferred archived user #{teacher_profile.user_id} to #{primary_user.id}")
    end

    def primary_user_for_trn(trn)
      Identity::PrimaryUser.find_by(trn:)
    end

    def archived_users_with_participant_profiles
      @archived_users_with_participant_profiles ||= User
        .archived
        .includes(:participant_profiles)
        .where.not(participant_profiles: { id: nil })
    end
  end
end
