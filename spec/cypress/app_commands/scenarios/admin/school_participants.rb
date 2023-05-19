# frozen_string_literal: true

school = FactoryBot.create :school, name: "Test School", slug: "test-school", urn: "123456"
cohort = FactoryBot.create :cohort, start_year: 2021
school_cohort = FactoryBot.create(:school_cohort, :cip, school:, cohort:)
induction_programme = FactoryBot.create(:induction_programme, school_cohort:)
mentor_1 = FactoryBot.create :mentor_participant_profile,
                             user: FactoryBot.create(:user, full_name: "Mentor User 1"),
                             school_cohort:,
                             created_at: Date.parse("20/03/2020")

mentor_2 = FactoryBot.create :mentor_participant_profile,
                             user: FactoryBot.create(:user, full_name: "Mentor User 2"),
                             school_cohort:,
                             created_at: Date.parse("06/05/2020")

ect_1 = FactoryBot.create :ect_participant_profile,
                          user: FactoryBot.create(:user, id: "05a85345-3d33-4bac-8152-07874b7ff328", full_name: "ECT User 1", email: "young_prosacco@crist.net"),
                          mentor_profile: mentor_1,
                          school_cohort:,
                          created_at: Date.parse("01/07/2020")

ect_2 = FactoryBot.create :ect_participant_profile,
                          user: FactoryBot.create(:user, full_name: "ECT User 2"),
                          mentor_profile: mentor_1,
                          school_cohort:,
                          created_at: Date.parse("25/05/2020")
[mentor_1, mentor_2, ect_1, ect_2].each do |ppt|
  Induction::Enrol.call(
    participant_profile: ppt,
    induction_programme:,
    start_date: 2.months.ago,
    mentor_profile: ppt.ect? ? mentor_1 : nil,
  )
  Mentors::AddToSchool.call(school:, mentor_profile: ppt) if ppt.mentor?
end

another_school = FactoryBot.create(:school, name: "Some other school", urn: "222222")
another_school_cohort = FactoryBot.create(:school_cohort, :cip, school: another_school, cohort:)

FactoryBot.create :mentor_participant_profile,
                  user: FactoryBot.create(:user, full_name: "Unrelated mentor"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("10/11/2020")

FactoryBot.create :ect_participant_profile,
                  user: FactoryBot.create(:user, full_name: "Unrelated ect"),
                  school_cohort: another_school_cohort,
                  created_at: Date.parse("29/12/2020")

%w[npq-specialist-spring npq-specialist-autumn].each do |schedule_identifier|
  FactoryBot.create(:npq_specialist_schedule, schedule_identifier:)
end
npq_course = FactoryBot.create(:npq_course, identifier: "npq-senior-leadership")
npq_user = FactoryBot.create(:user, full_name: "Natalie Portman Quebec", email: "natalie.portman@quebec.ca")

Timecop.freeze(Date.parse("19/09/2019")) do
  %w[npq-specialist-spring npq-specialist-autumn].each do |schedule_identifier|
    FactoryBot.create(:npq_specialist_schedule, schedule_identifier:)
  end
  %w[npq-leadership-spring npq-leadership-autumn].each do |schedule_identifier|
    FactoryBot.create(:npq_leadership_schedule, schedule_identifier:)
  end
  npq_application = FactoryBot.create(:npq_application,
                                      participant_identity: Identity::Create.call(user: npq_user, origin: :npq),
                                      date_of_birth: Date.parse("10/12/1982"),
                                      nino: "NI123456",
                                      teacher_reference_number: "9780824",
                                      school_urn: school.urn,
                                      npq_course:)

  NPQ::Application::Accept.new(npq_application:).call
end
