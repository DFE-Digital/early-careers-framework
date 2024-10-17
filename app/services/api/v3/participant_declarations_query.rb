# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsQuery
      include Api::Concerns::FilterCohorts
      include Api::Concerns::FilterUpdatedSince

      attr_reader :cpd_lead_provider, :params

      def initialize(cpd_lead_provider:, params:)
        @cpd_lead_provider = cpd_lead_provider
        @params = params
      end

      def participant_declarations_for_pagination
        filterable_attributes = %i[id created_at user_id updated_at delivery_partner_id type]
        scope = declaration_class.union(
          declarations_scope.select(*filterable_attributes),
          ecf_previous_declarations_scope.select(*filterable_attributes),
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
        scope = declaration_class
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
        ).call

        scope
      end

      def participant_declaration(id)
        declaration_class.union(
          declarations_scope,
          ecf_previous_declarations_scope,
        ).find(id)
      end

    private

      def lead_provider
        cpd_lead_provider.lead_provider if cpd_lead_provider.respond_to?(:lead_provider)
      end

      def npq_lead_provider
        cpd_lead_provider.npq_lead_provider if cpd_lead_provider.respond_to?(:npq_lead_provider)
      end

      def declarations_scope
        scope = declaration_class.for_lead_provider(cpd_lead_provider)
          .left_outer_joins(:cohort)
        filter_cohorts(scope)
      end

      def ecf_previous_declarations_scope
        scope = declaration_class
          .left_outer_joins(
            :cohort,
            participant_profile: [
              { induction_records: [
                { induction_programme: :partnership },
              ] },
            ],
          )
          .where(participant_profile: { induction_records: { induction_programme: { partnerships: { lead_provider_id: lead_provider&.id } } } })
          .where(participant_profile: { induction_records: { induction_status: "active" } }) # only want induction records that are the winning latest ones
          .where(state: %w[submitted eligible payable paid])

        scope = filter_cohorts(scope) if lead_provider.present?

        scope
      end

      def filter_cohorts(scope)
        return scope if cohort_years.blank?

        scope.where(cohort: { start_year: cohort_years })
      end

      def participant_ids
        filter[:participant_id]&.split(",")
      end

      def delivery_partner_ids
        filter[:delivery_partner_id]&.split(",")
      end

      def declaration_class
        if NpqApiEndpoint.disabled?
          ParticipantDeclaration::ECF
        else
          ParticipantDeclaration
        end
      end
    end
  end
end
