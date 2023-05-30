# frozen_string_literal: true

require "rails_helper"

RSpec.shared_context "a system that has one academic year configured with a training provider" do
  let!(:previous_cohort) do
    previous_cohort = NewSeeds::Scenarios::Cohorts::Cohort.new(2021)
                                                          .with_standard_schedule_and_first_milestone
                                                          .build
                                                          .cohort

    allow(Cohort).to receive(:previous).and_return(previous_cohort)

    previous_cohort
  end
  let!(:current_cohort) do
    allow(Cohort).to receive(:within_automatic_assignment_period?).and_return(false)
    allow(Cohort).to receive(:within_next_registration_period?).and_return(false)

    current_cohort = NewSeeds::Scenarios::Cohorts::Cohort.new(2022)
                                                         .with_standard_schedule_and_first_milestone
                                                         .build
                                                         .cohort

    allow(Cohort).to receive(:current).and_return(current_cohort)

    current_cohort
  end

  let!(:privacy_policy) do
    privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let!(:core_induction_programme) { create :seed_core_induction_programme, :valid }
  let!(:appropriate_body) { create :seed_appropriate_body, :valid }

  let(:school_builder) do
    school = NewSeeds::Scenarios::Schools::School.new
                                                 .build
                                                 .with_an_induction_tutor

    PrivacyPolicy.current.accept! school.induction_tutor
    school
  end

  let(:school) { school_builder.school }
  let(:academic_year) { current_cohort }

  before do
    travel_to Time.zone.local(academic_year.start_year, 6, 1, 9, 0, 0)
  end
end

RSpec.shared_context "a system that has a training provider" do
  let(:lead_provider_builder) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider.new("A training provider")
                                                    .with_contracted_cohorts([previous_cohort, current_cohort])
                                                    .with_user
                                                    .with_delivery_partner
                                                    .build
  end
  let!(:lead_provider) { lead_provider_builder.lead_provider }
  let!(:lead_provider_user) { lead_provider_builder.user }
  let!(:delivery_partner) { lead_provider_builder.delivery_partners.first }
end

RSpec.shared_context "a system that has a different training provider" do
  let(:different_lead_provider_builder) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider.new("A different training provider")
                                                    .with_contracted_cohorts([previous_cohort, current_cohort])
                                                    .with_user
                                                    .with_delivery_partner
                                                    .build
  end
  let!(:different_lead_provider) { different_lead_provider_builder.lead_provider }
  let!(:different_lead_provider_user) { different_lead_provider_builder.user }
  let!(:different_delivery_partner) { different_lead_provider_builder.delivery_partners.first }
end

RSpec.shared_examples "a school record" do
  it "has a school record" do
    expect(school).to be_a School
    expect(school.urn).to_not be_nil
    expect(school.name).to_not be_nil
  end
end

RSpec.shared_examples "a school with an known SIT record" do
  it "has a school with an known SIT record" do
    expect(school).to be_a School
    expect(school.induction_coordinator_profiles).to_not be_empty

    induction_coordinator_profile = school.induction_coordinator_profiles.first
    expect(induction_coordinator_profile).to be_an InductionCoordinatorProfile
  end
end

RSpec.shared_examples "a school with an associated school cohort record" do |start_year:|
  it "has a school with an associated school cohort record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.cohort).to eq Cohort.find_by(start_year:)
  end
end

RSpec.shared_examples "a school with a default core induction programme record" do |start_year:|
  it "has a school with a default core induction programme record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.default_induction_programme).to_not be_nil
    expect(school_cohort&.induction_programmes).to_not be_empty

    default_induction_programme = school_cohort&.default_induction_programme
    expect(default_induction_programme).to be_an InductionProgramme
    expect(default_induction_programme&.school_cohort).to eq school_cohort
    expect(default_induction_programme&.training_programme).to eq "core_induction_programme"

    expect(school_cohort&.induction_programmes).to include default_induction_programme
  end
end

RSpec.shared_examples "a school with a default full induction programme record" do |start_year:|
  it "has a school with a default full induction programme record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.default_induction_programme).to_not be_nil
    expect(school_cohort&.induction_programmes).to_not be_empty

    default_induction_programme = school_cohort&.default_induction_programme
    expect(default_induction_programme).to be_an InductionProgramme
    expect(default_induction_programme.school_cohort).to eq school_cohort
    expect(default_induction_programme.training_programme).to eq "full_induction_programme"
    expect(default_induction_programme.core_induction_programme).to be_nil

    expect(school_cohort&.induction_programmes).to include default_induction_programme
  end
end

RSpec.shared_examples "a school with a default diy induction programme record" do |start_year:|
  it "has a school with a default diy induction programme record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.default_induction_programme).to_not be_nil
    expect(school_cohort&.induction_programmes).to_not be_empty

    default_induction_programme = school_cohort&.default_induction_programme
    expect(default_induction_programme).to be_an InductionProgramme
    expect(default_induction_programme.school_cohort).to eq school_cohort
    expect(default_induction_programme.training_programme).to eq "design_our_own"
    expect(default_induction_programme.core_induction_programme).to be_nil

    expect(school_cohort&.induction_programmes).to include default_induction_programme
  end
end

RSpec.shared_examples "a school with no induction programme record" do |start_year:|
  it "has a school with no induction programme record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.default_induction_programme).to be_nil
    expect(school_cohort&.induction_programmes).to be_empty
  end
end

RSpec.shared_examples "a school with a CIP materials record" do |start_year:|
  it "has a school with a CIP materials record" do
    expect(school).to be_a School
    expect(school.school_cohorts).to_not be_empty

    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.core_induction_programme).to_not be_nil

    cip_materials = school_cohort&.core_induction_programme
    expect(cip_materials).to be_a CoreInductionProgramme

    default_induction_programme = school_cohort&.default_induction_programme
    expect(default_induction_programme.core_induction_programme).to eq cip_materials
  end
end

RSpec.shared_examples "a school with a partnership record" do |start_year:|
  it "has a school with a partnership record" do
    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    default_induction_programme = school_cohort&.default_induction_programme
    expect(default_induction_programme&.partnership).to_not be_nil

    partnership = default_induction_programme&.partnership
    expect(partnership).to be_a Partnership
    expect(partnership.challenge_reason).to be_nil
    expect(partnership.challenged_at).to be_nil
    expect(partnership.pending).to be false
    expect(partnership.cohort).to eq Cohort.find_by(start_year:)
    expect(partnership.school).to eq school
    expect(partnership.lead_provider).to be_a LeadProvider
    expect(partnership.delivery_partner).to be_a DeliveryPartner
  end
end

RSpec.shared_examples "a school with an appropriate body record" do |start_year:|
  it "has a school with an appropriate body record" do
    school_cohort = school.school_cohorts.for_year(start_year).first
    expect(school_cohort).to be_a SchoolCohort
    expect(school_cohort&.appropriate_body).to be_an AppropriateBody
  end
end

RSpec.shared_examples "a school that can add a participant" do |start_year:|
  it "can add a participant" do
    full_name = Faker::Name.name
    trn = Faker::Number.unique.rand_in_range(10_000, 100_000).to_s
    date_of_birth = Faker::Date.between(from: 70.years.ago, to: 21.years.ago)
    email_address = "#{full_name&.parameterize}.#{Faker::Alphanumeric.alpha(number: 5)}@example.com"
    start_term = "Summer term #{start_year}"

    dqt_record = DqtRecordPresenter.new({
      "name" => full_name,
      "trn" => trn,
      "state_name" => "Active",
      "dob" => date_of_birth,
      "qualified_teacher_status" => { "qts_date" => 1.month.ago },
    })
    dqt_response = DqtRecordCheck::CheckResult.new(dqt_record, true, true, true, false, 3)
    allow(DqtRecordCheck).to receive(:call).and_return(dqt_response)

    sign_in_as school.induction_tutor

    wizard = ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
    wizard.switch_to_manage_mentors_and_ects_dashboard
          .start_add_ect_or_mentor_wizard
          .add_ect(full_name:, trn:, date_of_birth:, email_address:, start_term:)

    sign_out
  end
end

RSpec.shared_examples "a school that can add a participant with an appropriate body" do |start_year:|
  it "can add a participant" do
    full_name = Faker::Name.name
    trn = Faker::Number.unique.rand_in_range(10_000, 100_000).to_s
    date_of_birth = Faker::Date.between(from: 70.years.ago, to: 21.years.ago)
    email_address = "#{full_name&.parameterize}.#{Faker::Alphanumeric.alpha(number: 5)}@example.com"
    start_term = "Summer term #{start_year}"

    dqt_record = DqtRecordPresenter.new({
      "name" => full_name,
      "trn" => trn,
      "state_name" => "Active",
      "dob" => date_of_birth,
      "qualified_teacher_status" => { "qts_date" => 1.month.ago },
    })
    dqt_response = DqtRecordCheck::CheckResult.new(dqt_record, true, true, true, false, 3)
    allow(DqtRecordCheck).to receive(:call).and_return(dqt_response)

    sign_in_as school.induction_tutor

    wizard = ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
    wizard.switch_to_manage_mentors_and_ects_dashboard
          .start_add_ect_or_mentor_wizard
          .add_ect_with_appropriate_body(full_name:, trn:, date_of_birth:, email_address:, start_term:)

    sign_out
  end
end

RSpec.shared_examples "a school that cannot add a participant without more information" do |start_year:|
  it "cannot add a participant" do
    full_name = Faker::Name.name
    trn = Faker::Number.unique.rand_in_range(10_000, 100_000).to_s
    date_of_birth = Faker::Date.between(from: 70.years.ago, to: 21.years.ago)
    email_address = "#{full_name&.parameterize}.#{Faker::Alphanumeric.alpha(number: 5)}@example.com"
    start_term = "Summer term #{start_year}"

    dqt_record = DqtRecordPresenter.new({
      "name" => full_name,
      "trn" => trn,
      "state_name" => "Active",
      "dob" => date_of_birth,
      "qualified_teacher_status" => { "qts_date" => 1.month.ago },
    })
    dqt_response = DqtRecordCheck::CheckResult.new(dqt_record, true, true, true, false, 3)
    allow(DqtRecordCheck).to receive(:call).and_return(dqt_response)

    sign_in_as school.induction_tutor

    wizard = ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
    wizard.switch_to_manage_mentors_and_ects_dashboard
          .start_add_ect_or_mentor_wizard
          .add_ect_without_enough_information(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          .cannot_register_ect?(full_name)

    sign_out
  end
end

RSpec.shared_examples "a school that needs to be setup" do
  it "needs to be setup" do
    sign_in_as school.induction_tutor

    ::Pages::Schools::Wizards::ChooseProgrammeWizard.loaded

    sign_out
  end
end
