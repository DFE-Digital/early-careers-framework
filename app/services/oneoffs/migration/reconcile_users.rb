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

    def indexes
      %i[
        id
        ecf_id
        get_an_identity_id
        trn
        npq_application_ecf_ids
      ].freeze
    end

  protected

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
      @ecf_users ||= begin
        applications_query = NPQApplication.joins(:participant_identity).where("participant_identities.user_id = users.id").select("ARRAY_AGG(npq_applications.id)")
        User.all.includes(:teacher_profile, participant_identities: :npq_applications).select("users.*", "(#{applications_query.to_sql}) AS npq_application_ecf_ids")
      end
    end

    def npq_users
      @npq_users ||= begin
        applications_query = NPQRegistration::Application.where("user_id = users.id AND ecf_id IS NOT NULL").select("ARRAY_AGG(ecf_id)")
        NPQRegistration::User.all.select("users.*", "(#{applications_query.to_sql}) AS npq_application_ecf_ids")
      end
    end
  end
end
