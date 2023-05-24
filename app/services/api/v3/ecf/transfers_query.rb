# frozen_string_literal: true

module Api
  module V3
    module ECF
      class TransfersQuery
        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def users
          scope = participants_with_school_transfer.or(leaving_participants)

          scope = User
            .includes(user_includes)
            .select("users.*", "induction_records.created_at")
            .distinct
            .joins("JOIN teacher_profiles ON users.id = teacher_profiles.user_id")
            .joins("JOIN (#{scope.to_sql}) AS participant_profiles ON participant_profiles.teacher_profile_id = teacher_profiles.id")
            .joins("JOIN induction_records ON participant_profiles.profile_id = induction_records.participant_profile_id")
            .where(
              participant_profiles: {
                induction_records: {
                  induction_status: "leaving",
                },
              },
            )

          if updated_since.present?
            scope = scope.where(updated_at: updated_since..)
          end

          scope.order("induction_records.created_at ASC")
        end

        def user
          users.find(params[:participant_id])
        end

      private

        attr_accessor :lead_provider, :params

        def filter
          params[:filter] ||= {}
        end

        def user_includes
          {
            participant_profiles: [
              induction_records:
              [
                :schedule,
                { induction_programme: [
                  school_cohort: :school,
                  partnership: :lead_provider,
                ] },
              ],
            ],
          }
        end

        def participants_with_school_transfer
          ParticipantProfile
            .select("participant_profiles.teacher_profile_id as teacher_profile_id", "participant_profiles.id as profile_id")
            .joins(
              induction_records: {
                induction_programme: :partnership,
              },
            )
            .where(
              induction_records: {
                school_transfer: true,
                induction_programmes: { partnerships: { lead_provider_id: lead_provider.id } },
              },
            )
        end

        def leaving_participants
          ParticipantProfile
            .select("participant_profiles.teacher_profile_id as teacher_profile_id", "participant_profiles.id as profile_id")
            .joins(
              induction_records: {
                induction_programme: :partnership,
              },
            )
            .where(
              induction_records: {
                induction_status: "leaving",
                induction_programmes: { partnerships: { lead_provider_id: lead_provider.id } },
              },
            )
        end

        def updated_since
          return if filter[:updated_since].blank?

          Time.iso8601(filter[:updated_since])
        rescue ArgumentError
          begin
            Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
          rescue ArgumentError
            raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
          end
        end
      end
    end
  end
end
