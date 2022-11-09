# frozen_string_literal: true

module Finance
  module NPQ
    module AssuranceReport
      class Query
        def initialize(statement)
          self.statement = statement
        end

        def participant_declarations
          @participant_declarations ||= ParticipantDeclaration::NPQ.find_by_sql(sql)
        end

      private

        attr_accessor :statement

        def sql
          <<~EOSQL
            SELECT
              pd.id                                   AS id,
              pi.external_identifier                  AS participant_id,
              u.full_name                             AS participant_name,
              tp.trn                                  AS trn,
              c.identifier                            AS course_identifier,
              sch.schedule_identifier                 AS schedule,
              a.eligible_for_funding                  AS eligible_for_funding,
              nlp.name                                AS npq_lead_provider_name,
              nlp.id                                  AS npq_lead_provider_id,
              a.school_urn                            AS school_urn,
              sc.name                                 AS school_name,
              pp.status                               AS training_status,
              pps.reason                              AS training_status_reason,
              pd.id                                   AS declaration_id,
              pd.state                                AS declaration_status,
              pd.declaration_type                     AS declaration_type,
              pd.declaration_date                     AS declaration_date,
              pd.created_at                           AS declaration_created_at,
              s.id                                    AS statement_id,
              s.name                                  AS statement_name,
              a.targeted_delivery_funding_eligibility AS targeted_delivery_funding
            FROM participant_declarations pd
            JOIN statement_line_items sli       ON sli.participant_declaration_id = pd.id
            JOIN statements s                   ON s.id = sli.statement_id
            JOIN cpd_lead_providers clp         ON clp.id = pd.cpd_lead_provider_id
            JOIN npq_lead_providers nlp         ON nlp.cpd_lead_provider_id = clp.id
            JOIN participant_profiles pp        ON pd.participant_profile_id = pp.id
            JOIN npq_applications a             ON a.id = pp.id
            JOIN npq_courses c                  ON c.id = a.npq_course_id
            JOIN participant_identities pi      ON pp.participant_identity_id = pi.id
            JOIN users u                        ON u.id = pi.user_id
            JOIN teacher_profiles tp            ON tp.id = pp.teacher_profile_id
            JOIN schedules sch                  ON sch.id = pp.schedule_id
            LEFT OUTER JOIN schools sc          ON sc.urn = pp.school_urn
            LEFT OUTER JOIN (
                 SELECT DISTINCT ON (cpd_lead_provider_id) cpd_lead_provider_id, participant_profile_id, state, reason
                 FROM participant_profile_states
                 ORDER BY cpd_lead_provider_id, created_at DESC
            ) AS pps ON pps.participant_profile_id = pp.id AND pd.cpd_lead_provider_id = pps.cpd_lead_provider_id AND pps.state = 'withdrawn'
            WHERE pd.type = 'ParticipantDeclaration::NPQ' AND #{where_values}
            ORDER BY u.full_name ASC
          EOSQL
        end

        def where_values
          ParticipantDeclaration::NPQ.sanitize_sql_for_conditions(["clp.id = ? AND s.id = ?", statement.cpd_lead_provider_id, statement.id])
        end
      end
    end
  end
end
