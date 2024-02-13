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

        to_user = primary_user(from_trn)

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

    def primary_user(trn)
      TeacherProfile
        .joins(:user)
        .includes(:user)
        .oldest_first
        .where(trn:)
        .first&.user
    end

    def flip_flop_users
      users = []

      ParticipantIdChange.find_each do |pic|
        if ParticipantIdChange.where(to_participant_id: pic.from_participant_id, from_participant_id: pic.to_participant_id).exists?
          users << pic.user
        end
      end

      users.uniq
    end
  end
end
