# frozen_string_literal: true

school = FactoryBot.create :school, name: "Test School", slug: "test-school", urn: "123456"
cohort = FactoryBot.create :cohort, start_year: 2021
school_cohort = FactoryBot.create(:school_cohort, :cip, school: school, cohort: cohort)

mentor_1 = FactoryBot.create :mentor_participant_profile,
                             user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                             school_cohort: school_cohort,
                             created_at: Date.parse("20/03/2020")

FactoryBot.create :mentor_participant_profile,
                  user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                  school_cohort: school_cohort,
                  created_at: Date.parse("06/05/2020")

FactoryBot.create :ect_participant_profile,
                  user: FactoryBot.create(:user, full_name: "ECT User 1", email: "young_prosacco@crist.net"),
                  mentor_profile: mentor_1,
                  school_cohort: school_cohort,
                  created_at: Date.parse("01/07/2020")

FactoryBot.create :ect_participant_profile,
                  user: FactoryBot.create(:user, full_name: "ECT User 2"),
                  mentor_profile: mentor_1,
                  school_cohort: school_cohort,
                  created_at: Date.parse("25/05/2020")

another_school = FactoryBot.create(:school, name: "Some other school", urn: "222222")
another_school_cohort = FactoryBot.create(:school_cohort, :cip, school: another_school, cohort: cohort)

FactoryBot.create :mentor_participant_profile,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("10/11/2020")

FactoryBot.create :ect_participant_profile,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("29/12/2020")

FactoryBot.create(:npq_specialist_schedule)
npq_course = FactoryBot.create(:npq_course, identifier: "npq-senior-leadership")
npq_user = FactoryBot.create(:user, full_name: "Natalie Portman Quebec", email: "natalie.portman@quebec.ca")

Timecop.freeze(Date.parse("19/09/2019")) do
  FactoryBot.create(:npq_leadership_schedule)
  FactoryBot.create(:npq_specialist_schedule)
  npq_application = FactoryBot.create :npq_application,
                                      participant_identity: Identity::Create.call(user:  npq_user, origin: :npq),
                                      date_of_birth: Date.parse("10/12/1982"),
                                      nino: "NI123456",
                                      teacher_reference_number: "9780824",
                                      school_urn: school.urn,
                                      npq_course: npq_course

  NPQ::Accept.new(npq_application: npq_application).call
end
