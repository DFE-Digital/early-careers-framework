\copy (
    SELECT s.urn        as school_urn,
          lp.name      as lead_provider_name,
          dp.name      as delivery_partner_name,
          p.created_at AS partnership_reported_at,
          p.challenge_reason,
          p.challenged_at
    FROM partnerships p
            JOIN lead_providers lp on lp.id = p.lead_provider_id
            JOIN delivery_partners dp on p.delivery_partner_id = dp.id
            JOIN schools s on p.school_id = s.id
) to '/tmp/exports/partnerships.csv' with csv header;
