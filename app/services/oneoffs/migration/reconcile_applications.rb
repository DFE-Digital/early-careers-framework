# frozen_string_literal: true

module Oneoffs::Migration
  class ReconcileApplications < Reconciler
  protected

    # We index on id to ensure all applications can be
    # indexed (as not all have an ecf_id).
    def indexes
      %i[
        id
        ecf_id
      ].freeze
    end

    def all_objects
      @all_objects ||= ecf_applications + npq_applications
    end

  private

    def ecf_applications
      @ecf_applications ||= NPQApplication.all
    end

    def npq_applications
      @npq_applications ||= NPQRegistration::Application.all
    end
  end
end
