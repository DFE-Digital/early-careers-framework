# frozen_string_literal: true

school = FactoryBot.create(:school, urn: "900499", name: "Optout High School")
lead_provider = FactoryBot.create(:lead_provider, name: "Fab Provider")
delivery_partner = FactoryBot.create(:delivery_partner, name: "Ranchero Partners")

FactoryBot.create(:user, :induction_coordinator, schools: [school], full_name: "Ted Tutor", email: "ted.tutor@example.com")

SchoolCohort.create!(school: school,
                     induction_programme_choice: "design_our_own",
                     opt_out_of_updates: true,
                     cohort: Cohort.current)

FactoryBot.create(:partnership,
                  :in_challenge_window,
                  delivery_partner: delivery_partner,
                  lead_provider: lead_provider,
                  school: school,
                  cohort: Cohort.current) 
