# frozen_string_literal: true

module Oneoffs::Migration
  class ReconcileUsers < Reconciler
    def matches
      @matches ||= super.reject { |match| ecf_orphan_with_no_applications?(match) }
    end

    def orphaned_matches
      @orphaned_matches ||= orphaned.map do |match|
        OrphanMatch.new(match.orphan, find_tentative_matches(match.orphan))
      end
    end

    def orphaned_ecf
      @orphaned_ecf ||= orphaned.select { |m| m.orphan.is_a?(User) }
    end

    def orphaned_npq
      @orphaned_npq ||= orphaned.select { |m| m.orphan.is_a?(NPQRegistration::User) }
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

    def find_tentative_matches(orphan)
      opposite_users(orphan)
        .reject { |u| u.applications.empty? }
        .select { |u| same_first_name?(u, orphan) && share_school?(u, orphan) }
    end

    def same_first_name?(user_a, user_b)
      user_a_first_name = user_a.full_name.split.first.downcase
      user_b.full_name.downcase.include?(user_a_first_name)
    end

    def share_school?(user_a, user_b)
      user_a_school_names = user_a.applications.map { |a| a.school&.name&.downcase }.compact
      user_b_school_names = user_b.applications.map { |b| b.school&.name&.downcase }.compact

      user_a_school_names.any? { |school_name| school_name.in?(user_b_school_names) }
    end

    def opposite_users(user)
      user.is_a?(User) ? npq_users : ecf_users
    end

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
        User.all.includes(:teacher_profile, participant_identities: :npq_applications).select("users.*", "(#{applications_query.to_sql}) AS npq_application_ecf_ids").to_a
      end
    end

    def npq_users
      @npq_users ||= begin
        applications_query = NPQRegistration::Application.where("user_id = users.id AND ecf_id IS NOT NULL").select("ARRAY_AGG(ecf_id)")
        NPQRegistration::User.all.select("users.*", "(#{applications_query.to_sql}) AS npq_application_ecf_ids").to_a
      end
    end
  end
end
