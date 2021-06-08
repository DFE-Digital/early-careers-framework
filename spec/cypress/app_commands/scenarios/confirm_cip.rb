# frozen_string_literal: true

cohort = FactoryBot.create(:cohort, start_year: 2021)

unconfirmed_user = FactoryBot.create(:user, :induction_coordinator, email: "confirm-provider@example.com")
SchoolCohort.find_or_create_by!(
  cohort: cohort,
  school: unconfirmed_user.induction_coordinator_profile.schools.first,
  induction_programme_choice: "full_induction_programme",
)

confirmed_user = FactoryBot.create(:user, :induction_coordinator, email: "signed-up-provider@example.com")
confirmed_school = confirmed_user.induction_coordinator_profile.schools.first
SchoolCohort.find_or_create_by!(
  cohort: cohort,
  school: confirmed_school,
  induction_programme_choice: "full_induction_programme",
)
delivery_partner = FactoryBot.create(:delivery_partner, name: "Test delivery partner")
lead_provider = FactoryBot.create(:lead_provider, name: "Test lead provider")

FactoryBot.create(
  :partnership,
  school: confirmed_school,
  cohort: cohort,
  delivery_partner: delivery_partner,
  lead_provider: lead_provider,
  created_at: Date.new(2021, 6, 7),
  challenge_deadline: Date.new(2025, 6, 7),
)
