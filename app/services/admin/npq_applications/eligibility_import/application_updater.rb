# frozen_string_literal: true

module Admin
  module NPQApplications
    module EligibilityImport
      class ApplicationUpdater
        attr_reader :application_updates, :user, :update_errors, :updated_records, :eligibility_import

        def initialize(application_updates:, user:, eligibility_import:)
          @eligibility_import = eligibility_import
          @application_updates = application_updates
          @user = user
          @update_errors = []
          @updated_records = 0
        end

        def update_applications
          application_updates.each(&method(:update_application))
        end

      private

        def valid_status_code?(application_update)
          NPQApplication::VALID_FUNDING_ELIGIBILITY_STATUS_CODES.include?(application_update.funding_eligiblity_status_code)
        end

        def build_error_message(csv_row:, message:)
          "ROW #{csv_row}: #{message}"
        end

        def update_application(application_update)
          error_message = nil
          csv_row = application_update.csv_row
          application_id = application_update.ecf_id

          application = NPQApplication.find_by(id: application_id)

          if application.present?
            # Don't allow status codes to be set to anything other than the codes we expect from the NPQ application.
            # This is to guard against misunderstandings where this column is assumed to be freeform data.
            # The validation isn't on the model because we don't want to block the NPQ application from
            # implementing new status codes.
            if valid_status_code?(application_update)
              update_params = {
                eligible_for_funding: application_update.eligible_for_funding,
                funding_eligiblity_status_code: application_update.funding_eligiblity_status_code,
              }

              if application.update(update_params)
                @updated_records += 1
              else
                error_message = "Application with ecf_id #{application_id} invalid: #{application.errors.full_messages.join(', ')}"
              end
            else
              error_message = "Application with ecf_id #{application_id} invalid: Invalid funding eligibility status code, `#{application_update.funding_eligiblity_status_code}`"
            end
          else
            error_message = "Application with ecf_id #{application_id} not found"
          end

          update_errors.append(build_error_message(csv_row:, message: error_message)) if error_message.present?
        rescue StandardError => e
          Sentry.with_scope do |scope|
            scope.set_context("NPQ Eligibility Import Record", id: eligibility_import.id)
            scope.set_context("NPQ Application Record", id: application_update.ecf_id)
            Sentry.capture_exception(e)
          end

          error_message = build_error_message(
            csv_row:,
            message: "Could not update Application with ecf_id #{application_id}, contact an administrator for details",
          )

          update_errors.append(error_message)
        end
      end
    end
  end
end
