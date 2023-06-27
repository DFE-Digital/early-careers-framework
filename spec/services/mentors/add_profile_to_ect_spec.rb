# frozen_string_literal: true

RSpec.describe Mentors::AddProfileToECT do
  let(:school) { create(:school) }
  let(:pupil_premium_school) { create :school, :pupil_premium_uplift, start_year: 2022 }
  let(:sparsity_school) { create :school, :sparsity_uplift, start_year: 2022 }
  let(:uplift_school) { create :school, :pupil_premium_and_sparsity_uplift, start_year: 2022 }
  let(:school_cohort_21) { create(:school_cohort, :fip, :with_ecf_standard_schedule, school:, cohort: Cohort.find_or_create_by!(start_year: 2021)) }
  let(:school_cohort_22) { create(:school_cohort, :fip, :with_ecf_standard_schedule, school:, cohort: Cohort.find_or_create_by!(start_year: 2022)) }
  let(:ect_profile) { create(:ect_participant_profile, :ecf_participant_validation_data, :ecf_participant_eligibility, school_cohort: school_cohort_21) }
  let(:preferred_email) { "mary.mentor@example.com" }

  let(:validation_result) do
    {
      trn: ect_profile.teacher_profile.trn,
      qts: false,
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
      no_induction: false,
      exempt_from_induction: false,
    }
  end

  subject(:service_call) { described_class.call(ect_profile:, school_cohort: school_cohort_22, preferred_email:) }

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return(validation_result)
  end

  it "creates a Mentor record" do
    expect { service_call }.to change { ect_profile.teacher_profile.ecf_profiles.mentors.count }.by(1)
  end

  it "adds the mentor to the school mentors pool" do
    expect { service_call }.to change { school.school_mentors.count }.by(1)
  end

  it "is created under the same participant identity as the ECT" do
    mentor_profile = service_call
    expect(mentor_profile.participant_identity_id).to eq ect_profile.participant_identity_id
  end

  it "copies the validation data from the ECT profile" do
    mentor_profile = service_call
    expect(mentor_profile.ecf_participant_validation_data.attributes).to match(
      hash_including(ect_profile.ecf_participant_validation_data.attributes.except(*%w[id participant_profile_id created_at updated_at])),
    )
  end

  it "reevaluates the participants eligibility" do
    StoreValidationResult.call(participant_profile: ect_profile, validation_data: nil, dqt_response: validation_result)
    expect(ect_profile.reload).not_to be_fundable

    mentor_profile = service_call
    expect(mentor_profile.reload).to be_fundable
  end

  context "when default induction programme is set on the school cohort" do
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort_22) }

    before do
      school_cohort_22.update_column(:default_induction_programme_id, induction_programme.id)
    end

    it "enrolls the mentor into the default induction programme for the school cohort" do
      expect { service_call }.to change { induction_programme.induction_records.count }.by(1)
    end

    it "enrolls the mentor with the preferred email address" do
      mentor_profile = service_call
      expect(mentor_profile.current_induction_record.preferred_identity.email).to eq preferred_email
    end

    context "when preferred_email is not set" do
      let(:preferred_email) { nil }

      it "enrolls the mentor with the participant_identity email" do
        mentor_profile = service_call
        expect(mentor_profile.current_induction_record.preferred_identity.email).to eq mentor_profile.participant_identity.email
      end
    end
  end

  context "when there is no default induction programme set" do
    it "does not enrol the mentor" do
      expect { service_call }.not_to change { InductionRecord.count }
    end
  end

  context "when the school does not have uplifts" do
    it "does not set any uplift flags on the profile" do
      mentor_profile = service_call
      expect(mentor_profile).not_to be_pupil_premium_uplift
      expect(mentor_profile).not_to be_sparsity_uplift
    end
  end

  context "when the school has pupil premium uplift" do
    let(:school_cohort_22) { create(:school_cohort, :fip, :with_ecf_standard_schedule, school: pupil_premium_school, cohort: Cohort.find_or_create_by!(start_year: 2022)) }

    it "sets pupil_premium_uplift on the profile" do
      mentor_profile = service_call
      expect(mentor_profile).to be_pupil_premium_uplift
      expect(mentor_profile).not_to be_sparsity_uplift
    end
  end

  context "when the school has sparsity uplift" do
    let(:school_cohort_22) { create(:school_cohort, :fip, :with_ecf_standard_schedule, school: sparsity_school, cohort: Cohort.find_or_create_by!(start_year: 2022)) }

    it "sets sparsity_uplift on the profile" do
      mentor_profile = service_call
      expect(mentor_profile).not_to be_pupil_premium_uplift
      expect(mentor_profile).to be_sparsity_uplift
    end
  end

  context "when the school has pupil premium and sparsity uplifts" do
    let(:school_cohort_22) { create(:school_cohort, :fip, :with_ecf_standard_schedule, school: uplift_school, cohort: Cohort.find_or_create_by!(start_year: 2022)) }

    it "sets both sparsity_uplift and pupil_premium_uplift on the profile" do
      mentor_profile = service_call
      expect(mentor_profile).to be_pupil_premium_uplift
      expect(mentor_profile).to be_sparsity_uplift
    end
  end

  it "records the profile for analytics" do
    # creates and updates to ect and mentor profiles are recorded
    expect { service_call }.to have_enqueued_job(Analytics::UpsertECFParticipantProfileJob).at_least(2).times
  end
end
