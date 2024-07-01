# frozen_string_literal: true

module Archive
  class UnvalidatedUser < ::BaseService
    include Archive::SupportMethods

    def call
      check_user_can_be_archived!

      data = Archive::UserSerializer.new(user).serializable_hash[:data]

      ActiveRecord::Base.transaction do
        relic = Archive::Relic.create!(object_type: user.class.name,
                                       object_id: user.id,
                                       display_name: user.full_name,
                                       reason:,
                                       data:)
        destroy_user! unless keep_original
        relic
      end
    end

  private

    attr_accessor :user, :reason, :keep_original

    def initialize(user, reason: "unvalidated/undeclared ECTs 2021 or 2022", keep_original: false)
      @user = user
      @reason = reason
      @keep_original = keep_original
    end

    def check_user_can_be_archived!
      if users_excluded_roles.any?
        raise ArchiveError, "User #{user.id} has excluded roles: #{users_excluded_roles.join(',')}"
      elsif user_has_declarations?
        raise ArchiveError, "User #{user.id} has non-voided declarations"
      elsif user_has_eligibility?
        raise ArchiveError, "User #{user.id} has an eligibility record"
      elsif user_has_mentees?
        raise ArchiveError, "User #{user.id} has mentees"
      elsif user_has_been_transferred?
        raise ArchiveError, "User #{user.id} has transfer records"
      elsif user_has_gai_id?
        raise ArchiveError, "User #{user.id} has a Get an Identity ID"
      elsif user_is_mentor_on_declarations?
        raise ArchiveError, "User #{user.id} is mentor on declarations"
      end
    end
  end
end
