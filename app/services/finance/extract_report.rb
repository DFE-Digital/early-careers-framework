# frozen_string_literal: true

module Finance
  class ExtractReport
    def npq
      raw_connection.copy_data(npq_sql) do
        while (row = raw_connection.get_copy_data)
          puts row.force_encoding("UTF-8")
        end
      end
    end

  private

    def connection
      @connection ||= ApplicationRecord.connection
    end

    def raw_connection
      @raw_connection ||= connection.raw_connection
    end

    def npq_sql
      <<-SQL
        COPY (SELECT
              clp.name                                               AS lead_provider_name,
                na.school_urn                                        AS school_urn,
                na.eligible_for_funding                              AS eligible_for_funding,
                (SELECT name FROM schools WHERE urn = na.school_urn) AS school_name,
                pd.user_id                                           AS participant_id,
                tp.trn                                               AS participant_trn,
                pp.id                                                AS application_id,
                pps.state                                            AS training_status,
                pps.reason                                           AS training_status_reason,
                pd.course_identifier                                 AS course_identifier,
                pd.id                                                AS declaration_id,
                pd.declaration_date                                  AS declaration_date,
                pd.declaration_type                                  AS declaration_type,
                pd.updated_at                                        AS declaration_updated_at,
                pd.state                                             AS declaration_state,
                sc.name                                              AS schedule_name,
                statements.name                                      AS statement
              FROM participant_declarations pd
              JOIN cpd_lead_providers clp  ON clp.id = pd.cpd_lead_provider_id
              JOIN participant_profiles pp ON pp.id  = pd.participant_profile_id
              LEFT OUTER JOIN (
                SELECT pp.id, pps.state, pps.reason
                FROM participant_profiles pp
                JOIN (
                  SELECT participant_profile_id, state, reason, MAX(created_at)
                  FROM participant_profile_states
                  GROUP BY participant_profile_id, state, reason
                ) pps ON pps.participant_profile_id = pp.id
              ) pps ON pps.id = pp.id
              JOIN teacher_profiles tp  ON tp.id  = pp.teacher_profile_id
              JOIN npq_applications na  ON na.id  = pd.participant_profile_id
              JOIN statement_line_items ON statement_line_items.participant_declaration_id = pd.id
              JOIN statements           ON statements.id = statement_line_items.statement_id
              JOIN schedules sc         ON sc.id  = pp.schedule_id
              WHERE pd.type = 'ParticipantDeclaration::NPQ'
              ORDER BY clp.name ASC, school_name ASC, course_identifier ASC) TO STDOUT WITH CSV DELIMITER ',' HEADER;
      SQL
    end
  end
end
