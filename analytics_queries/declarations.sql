\copy (
    SELECT pd.id,
          pd.user_id,
          pd.declaration_type,
          pd.declaration_date,
          (pd.state = 'voided') as voided,
          pd.evidence_held,
          pd.state,
          pds.state_reason
    FROM participant_declarations pd
    LEFT JOIN declaration_states pds on pd.id = pds.participant_declaration_id and pd.state = pds.state
    WHERE course_identifier in ('ecf-induction', 'ecf-mentor')
) to '/tmp/exports/declarations.csv' with csv header;
