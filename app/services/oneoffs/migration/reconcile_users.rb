# frozen_string_literal: true

module Oneoffs::Migration
  class ReconcileUsers < Reconciler
    def matches
      @matches ||= super.reject { |match| ecf_orphan_with_no_applications?(match) }
    end

    def orphaned_ecf
      orphaned.select { |m| m.orphan.is_a?(User) }
    end

    def orphaned_npq
      orphaned.select { |m| m.orphan.is_a?(NPQRegistration::User) }
    end

  protected

    def indexes
      %i[
        ecf_id
        get_an_identity_id
        trn
        email
      ].freeze
    end

    def all_objects
      @all_objects ||= ecf_users + npq_users
    end

  private

    def ecf_orphan_with_no_applications?(match)
      return unless match.orphaned?
      return unless match.orphan.is_a?(User)

      !match.orphan.id.in?(ecf_user_ids_with_npq_applications)
    end

    def ecf_user_ids_with_npq_applications
      @ecf_user_ids_with_npq_applications ||= Set.new(
        User.includes(participant_identities: :npq_applications)
          .where.not(npq_applications: { id: nil })
          .pluck(:id),
      )
    end

    def ecf_users
      @ecf_users ||= User.all
        .includes(:teacher_profile, participant_identities: :npq_applications)
    end

    def npq_users
      @npq_users ||= NPQRegistration::User.all
    end
  end
end
