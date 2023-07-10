# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsQuery
      include Concerns::FilterCohorts
      include Concerns::FilterUpdatedSince

      attr_reader :cpd_lead_provider, :params

      def initialize(cpd_lead_provider:, params:)
        @cpd_lead_provider = cpd_lead_provider
        @params = params
      end

      def participant_declarations_for_pagination
        filterable_attributes = %i[id created_at user_id updated_at delivery_partner_id]
        scope = ParticipantDeclaration.union(
          declarations_scope.select(*filterable_attributes),
          previous_declarations_scope.select(*filterable_attributes),
        )

        if participant_ids.present?
          scope = scope.where(user_id: participant_ids)
        end

        if updated_since_filter.present?
          scope = scope.where(updated_at: updated_since..)
        end

        if delivery_partner_ids.present?
          scope = scope.where(delivery_partner_id: delivery_partner_ids)
        end

        scope
         .select(:id, :created_at)
         .order(:created_at)
      end

      def participant_declarations_from(paginated_join)
        scope = ParticipantDeclaration
            .includes(
              :statement_line_items,
              :declaration_states,
              :participant_profile,
              :cpd_lead_provider,
            )
            .joins("INNER JOIN (#{paginated_join.to_sql}) as tmp on tmp.id = participant_declarations.id")
            .order(:created_at)
            .distinct

        ActiveRecord::Associations::Preloader.new(
          records: scope.select { |p| p.type == "ParticipantDeclaration::NPQ" },
          associations: [:outcomes, { participant_profile: :npq_application }],
        )

        scope
      end

    private

      delegate :lead_provider, to: :cpd_lead_provider

      def declarations_scope
        scope = ParticipantDeclaration.for_lead_provider(cpd_lead_provider)

        if cohort_years.present?
          scope = with_joins(scope)
          scope = scope.where(participant_profile: { induction_records: { cohorts: { start_year: cohort_years } } })
        end

        scope
      end

      def previous_declarations_scope
        scope = with_joins(ParticipantDeclaration)
          .where(participant_profile: { induction_records: { induction_programme: { partnerships: { lead_provider_id: lead_provider.id } } } })
          .where(participant_profile: { induction_records: { induction_status: "active" } }) # only want induction records that are the winning latest ones
          .where(state: %w[submitted eligible payable paid])

        if cohort_years.present?
          scope = scope.where(participant_profile: { induction_records: { cohorts: { start_year: cohort_years } } })
        end

        scope
      end

      def participant_ids
        filter[:participant_id]&.split(",")
      end

      def delivery_partner_ids
        filter[:delivery_partner_id]&.split(",")
      end

      def with_joins(scope)
        scope.left_outer_joins(
          participant_profile: [
            induction_records: [
              :cohort,
              { induction_programme: :partnership },
            ],
          ],
        )
      end
    end
  end
end
