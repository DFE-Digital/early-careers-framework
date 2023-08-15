# frozen_string_literal: true

fip_school = NewSeeds::Scenarios::Schools::School
               .new(name: "GDPR Requests school", ukprn: 10_052_528)
               .build
               .with_an_induction_tutor(full_name: "GDPR Requests school SIT", email: "gdpr-requests-school@example.com")
               .chosen_fip_and_partnered_in(cohort: Cohort.current)

school_cohort = fip_school.school_cohort

# cpd_lead_provider is not created by default
ecf_lead_provider = school_cohort.default_induction_programme.partnership.lead_provider
cpd_lead_provider = FactoryBot.create(:seed_cpd_lead_provider, name: ecf_lead_provider.name)
ecf_lead_provider.update!(cpd_lead_provider:)

Rails.logger.debug("Creating GDPR request scenario MentorWithNPQApplication")

NewSeeds::Scenarios::Participants::Mentors::MentorWithNPQApplication.new(school_cohort:, full_name: "Mentor: With NPQ Application")
                                                                    .build
