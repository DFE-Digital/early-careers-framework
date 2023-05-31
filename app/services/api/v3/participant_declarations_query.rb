# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsQuery
      attr_reader :cpd_lead_provider, :params

      def initialize(cpd_lead_provider:, params:)
        @cpd_lead_provider = cpd_lead_provider
        @params = params
      end

      def participant_declarations
        scope = ActiveRecordUnion.new(
          declarations_scope,
          previous_declarations_scope,
        ).call

        if participant_ids.present?
          scope = scope.where(user_id: participant_ids)
        end

        if updated_since.present?
          scope = scope.where(updated_at: updated_since..)
        end

        if delivery_partner_ids.present?
          scope = scope.where(delivery_partner_id: delivery_partner_ids)
        end

        scope = scope.includes(
          :statement_line_items,
          :declaration_states,
          :participant_profile,
          :cpd_lead_provider,
        )
        .joins(participant_profile: :induction_records)
        .joins(join_latest_induction_records)
        .joins(left_outer_join_mentor_profiles)
        .joins(left_outer_join_mentor_participant_identities)
        .select("participant_declarations.*", "participant_identities_mentor_profiles.user_id AS mentor_user_id")

        scope.order(:created_at)
      end

    private

      delegate :lead_provider, to: :cpd_lead_provider

      def latest_induction_record_order
        <<~SQL
          PARTITION BY induction_records.participant_profile_id ORDER BY
            CASE
              WHEN induction_records.end_date IS NULL
                THEN 1
              ELSE 2
            END,
            induction_records.start_date DESC,
            induction_records.created_at DESC
        SQL
      end

      def join_latest_induction_records
        join = InductionRecord
         .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id")
         .joins(:participant_profile, :schedule, { induction_programme: :partnership })
         .where(
           induction_programme: {
             partnerships: {
               lead_provider_id: lead_provider.id,
             },
           },
         )

        "JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id"
      end

      def left_outer_join_mentor_profiles
        "LEFT OUTER JOIN participant_profiles mentor_profiles ON mentor_profiles.id = induction_records.mentor_profile_id"
      end

      def left_outer_join_mentor_participant_identities
        "LEFT OUTER JOIN participant_identities participant_identities_mentor_profiles ON participant_identities_mentor_profiles.id = mentor_profiles.participant_identity_id"
      end

      def declarations_scope
        scope = with_joins(ParticipantDeclaration.for_lead_provider(cpd_lead_provider))

        if cohort_start_years.present?
          scope = scope.where(participant_profile: { induction_records: { cohorts: { start_year: cohort_start_years } } })
        end

        scope
      end

      def previous_declarations_scope
        scope = with_joins(ParticipantDeclaration)
          .where(participant_profile: { induction_records: { induction_programme: { partnerships: { lead_provider: } } } })
          .where(participant_profile: { induction_records: { induction_status: "active" } }) # only want induction records that are the winning latest ones
          .where(state: %w[submitted eligible payable paid])

        if cohort_start_years.present?
          scope = scope.where(participant_profile: { induction_records: { cohorts: { start_year: cohort_start_years } } })
        end

        scope
      end

      def filter
        params[:filter] ||= {}
      end

      def participant_ids
        filter[:participant_id]&.split(",")
      end

      def delivery_partner_ids
        filter[:delivery_partner_id]&.split(",")
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

      def cohort_start_years
        filter[:cohort]&.split(",")
      end

      def with_joins(scope)
        scope.left_outer_joins(
          participant_profile: [
            induction_records: [
              :cohort,
              { induction_programme: { partnership: [:lead_provider] } },
            ],
          ],
        )
      end
    end
  end
end
