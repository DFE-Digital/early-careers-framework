# frozen_string_literal: true

school = FactoryBot.create(:school, name: "Test school", slug: "111111-test-school")
delivery_partner = FactoryBot.create(:delivery_partner, name: "Test delivery partner")
cohort = Cohort.find_or_create_by!(start_year: 2021)
user = FactoryBot.create(:user, :induction_coordinator, schools: [school], email: "test-subject@example.com")
partnership = FactoryBot.create(:partnership, :in_challenge_window, school: school, cohort: cohort, delivery_partner: delivery_partner)
SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")
PartnershipNotificationEmail.create!(
  token: "abc123",
  sent_to: user.email,
  partnership: partnership,
  email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
)

school = FactoryBot.create(:school, name: "Test school 2")
delivery_partner = FactoryBot.create(:delivery_partner, name: "Test delivery partner 2")
partnership = FactoryBot.create(
  :partnership,
  school: school,
  cohort: cohort,
  delivery_partner: delivery_partner,
  created_at: 20.days.ago,
  challenge_deadline: 6.days.ago,
)
PartnershipNotificationEmail.create!(
  token: "expired",
  sent_to: user.email,
  partnership: partnership,
  email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
  created_at: 20.days.ago,
)

school = FactoryBot.create(:school, name: "Test school 3", slug: "111113-test-school-3")
user = FactoryBot.create(:user, :induction_coordinator, schools: [school], email: "test-subject2@example.com")
partnership = FactoryBot.create(:partnership, challenge_deadline: Time.utc(2099, 1, 1), school: school, cohort: cohort, delivery_partner: delivery_partner, pending: true)
SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")
PartnershipNotificationEmail.create!(
  token: "abc1234",
  sent_to: user.email,
  partnership: partnership,
  email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
)
