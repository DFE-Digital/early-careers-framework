SELECT pd.id,
       pd.user_id,
       pd.declaration_type,
       pd.declaration_date,
       (pd.state = 'voided') as voided,
       pd.evidence_held
FROM participant_declarations pd
WHERE course_identifier in ('ecf-induction', 'ecf-mentor');