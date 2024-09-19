# frozen_string_literal: true

module Oneoffs::NPQ::DataCleanup
  class FixApplicationsInECFNotInNPQ
    attr_reader :npq_application_ids

    def initialize(npq_application_ids:)
      @npq_application_ids = npq_application_ids
    end

    def run!(dry_run: true)
      result = {}

      ActiveRecord::Base.transaction do
        result = npq_application_ids.each_with_object({}) do |npq_application_id, hash|
          npq_application = NPQApplication.find_by(id: npq_application_id)
          unless npq_application
            hash[npq_application_id] = "Not found #{npq_application_id}. Might have already been deleted."
            next
          end

          # Other applications for the same user/course/lead_provider/cohort
          similar_applications = similar_applications(npq_application:)

          # Where there is only one accepted similar application
          # We keep the accepted one and delete the one which does not exist in NPQ.
          similar_applications.select(&:accepted?)
          if similar_applications.select(&:accepted?).one? && !npq_application.accepted?
            npq_application.destroy!
            hash[npq_application_id] = "There's an accepted application. Delete: #{[npq_application.npq_lead_provider.name, npq_application.user_id, npq_application.id]}"
            next
          end

          # Where the application is accepted and all similar ones are rejected.
          # We keep the accepted one and update NPQ accordingly.
          # Also delete all the ones which does not exist in NPQ.
          if npq_application.accepted? && similar_applications.any? && similar_applications.all?(&:rejected?)
            similar_application_ids = similar_applications.map(&:id)
            applications_ids_to_be_deleted = npq_application_ids & similar_application_ids
            applications_to_be_deleted = NPQApplication.where(id: applications_ids_to_be_deleted).destroy_all
            hash[npq_application_id] = "Keep #{npq_application.id}. Sync up in NPQ accordingly. Delete #{applications_to_be_deleted.map { |app| [app.npq_lead_provider.name, app.user_id, app.id] }}"
            next
          end

          # Where the application is pending and all similar ones are also pending.
          # We keep the latest one and update NPQ accordingly.
          # Also delete all the ones which does not exist in NPQ.
          if npq_application.pending? && similar_applications.size.positive? && similar_applications.all?(&:pending?)
            similar_application_ids = similar_applications.map(&:id)
            similar_application_ids.delete_at(0) # remove first one
            applications_ids_to_be_deleted = npq_application_ids & similar_application_ids
            applications_to_be_deleted = NPQApplication.where(id: applications_ids_to_be_deleted).destroy_all
            hash[npq_application_id] = "Keep #{similar_applications.first.id}. Sync up in NPQ accordingly. Delete #{applications_to_be_deleted.map { |app| [app.npq_lead_provider.name, app.user_id, app.id] }}"
            next
          end

          # Application is rejected, and all similar ones are also rejected.
          # We delete all the ones which does not exist in NPQ.
          if npq_application.rejected? && similar_applications.size.positive? && similar_applications.all?(&:rejected?)
            similar_application_ids = similar_applications.map(&:id)
            applications_ids_to_be_deleted = npq_application_ids & similar_application_ids
            applications_to_be_deleted = NPQApplication.where(id: applications_ids_to_be_deleted).destroy_all
            hash[npq_application_id] = "Delete #{applications_to_be_deleted.map { |app| [app.npq_lead_provider.name, app.user_id, app.id] }}"
            next
          end

          # Application is accepted, so we need to keep it and update NPQ accordingly
          if npq_application.accepted?
            hash[npq_application_id] = "Keep #{npq_application.id}. Sync up in NPQ accordingly."
            next
          end
        end

        raise ActiveRecord::Rollback if dry_run
      end

      result
    end

  private

    def user_applications(npq_application:)
      npq_application.user.npq_applications.order(created_at: :desc)
    end

    def similar_applications(npq_application:)
      user_applications(npq_application:).select do |a|
        a.id != npq_application.id &&
          a.npq_course == npq_application.npq_course &&
          a.cohort == npq_application.cohort &&
          a.npq_lead_provider == npq_application.npq_lead_provider
      end
    end
  end
end
