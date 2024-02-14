# frozen_string_literal: true

module Oneoffs
  class FlipflopUsersCleanup
    def call
      result = []

      flip_flop_users.each do |from_user|
        if from_user.archived?
          result << [from_user.id, "User is archived"]
          next
        end

        from_trn = from_user.teacher_profile.trn
        if from_trn.blank?
          result << [from_user.id, "TRN does not exist"]
          next
        end

        to_user = Identity::PrimaryUser.find_by(trn: from_trn)

        if from_user == to_user
          result << [from_user.id, "already the primary user"]
          next
        end

        if to_user.archived?
          result << [from_user.id, "to_user [#{to_user.id}] is archived"]
          next
        end

        Identity::Transfer.call(from_user:, to_user:)
        result << [from_user.id, "transfer to user [#{to_user.id}]"]
      end

      result
    end

    def flip_flop_users
      ids = ParticipantIdChange
        .joins("INNER JOIN participant_id_changes a ON participant_id_changes.from_participant_id = a.to_participant_id")
        .joins("INNER JOIN participant_id_changes b ON participant_id_changes.to_participant_id = b.from_participant_id")
        .pluck(:user_id)
      User.where(id: ids)
    end
  end
end
