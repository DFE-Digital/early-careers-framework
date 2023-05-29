# frozen_string_literal: true

require "rails_helper"

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
  it "can add a participant", :skip do
    participant_name = Faker::Name.name
    participant_trn = Faker::Number.unique.rand_in_range(10_000, 100_000).to_s
    participant_dob = Faker::Date.between(from: 70.years.ago, to: 21.years.ago)
    participant_email = "#{participant_name&.parameterize}.#{Faker::Alphanumeric.alpha(number: 5)}@example.com"

    sign_in_as school.induction_tutor

    wizard = Pages::SchoolDashboardPage.loaded
                                       .add_participant_details
                                       .choose_to_add_an_ect_or_mentor

    participant_start_date = Date.new(start_year, 9, 5)

    dqt_response = DqtRecordCheck::CheckResult.new(
      {
        "name" => participant_name,
        "trn" => participant_trn,
        "state_name" => "Active",
        "dob" => participant_dob,
        "qualified_teacher_status" => { "qts_date" => 1.month.ago },
        "induction" => {
          "start_date" => participant_start_date,
          "status" => "Active",
        },
      },
      true,
      true,
      true,
      false,
      3,
    )
    allow(DqtRecordCheck).to receive(:call).and_return(dqt_response)

    validation_response = {
      trn: participant_trn,
      qts: true,
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
      no_induction: false,
      exempt_from_induction: false,
    }
    allow(ParticipantValidationService).to receive(:validate).and_return(validation_response)

    wizard.add_ect participant_name, participant_trn, participant_dob, participant_email, participant_start_date

    sign_out
  end
end

RSpec.shared_examples "a school that needs to be setup" do
  it "needs to be setup", :skip do
  end
end

RSpec.shared_examples "a school that cannot add a participant" do
  it "cannot add a participant", :skip do
  end
end
