# frozen_string_literal: true

module Oneoffs::Migration
  class ReconcileApplications < Reconciler
    def orphaned_matches
      @orphaned_matches ||= orphaned.map do |match|
        OrphanMatch.new(match.orphan, find_tentative_matches(match.orphan))
      end
    end

    def indexes
      %i[
        id
        ecf_id
      ].freeze
    end

    def orphaned_ecf
      @orphaned_ecf ||= orphaned.select { |m| m.orphan.is_a?(NPQApplication) }
    end

    def orphaned_npq
      @orphaned_npq ||= orphaned.select { |m| m.orphan.is_a?(Migration::NPQRegistration::Source::Application) }
    end

  protected

    def all_objects
      @all_objects ||= ecf_applications + npq_applications
    end

  private

    def find_tentative_matches(orphan)
      orphan_course_name = orphan.course.name

      opposite_applications(orphan)
        .select { |a| a.course.name.downcase == orphan_course_name.downcase }
        .select { |a| a.user.ecf_id == orphan.user.ecf_id }
    end

    def opposite_applications(application)
      application.is_a?(NPQApplication) ? npq_applications : ecf_applications
    end

    def ecf_applications
      @ecf_applications ||= NPQApplication.includes(:npq_course, participant_identity: :user).all.to_a
    end

    def npq_applications
      @npq_applications ||= Migration::NPQRegistration::Source::Application.includes(:course, :user).all.to_a
    end
  end
end
