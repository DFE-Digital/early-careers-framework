# frozen_string_literal: true

module Oneoffs::Migration
  class ReconcileApplications < Reconciler
    def orphaned_matches
      @orphaned_matches ||= orphaned.map { |match| OrphanMatch.new(match.orphan, find_tentative_matches(match.orphan)) }
    end

    def indexes
      %i[
        id
        ecf_id
      ].freeze
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
      @ecf_applications ||= NPQApplication.all
    end

    def npq_applications
      @npq_applications ||= NPQRegistration::Application.all
    end
  end
end
