# frozen_string_literal: true

RSpec.describe Schools::Year2020Form, type: :model do
  let!(:school) { create :school }
  let!(:cohort) { create :cohort, start_year: 2020 }
  let!(:core_induction_programme) { create :core_induction_programme }

  subject { described_class.new(school_id: school.id) }

  it { is_expected.to validate_presence_of(:induction_programme_choice).on(:choose_induction_programme) }
  it { is_expected.to validate_presence_of(:core_induction_programme_id).on(:choose_cip) }
  it { is_expected.to validate_presence_of(:full_name).on(:create_teacher) }
  it { is_expected.to validate_presence_of(:email).on(:create_teacher) }

  describe "save!" do
    it "creates a school cohort and user when given all details" do
      subject.full_name = "Test User"
      subject.email = "ray.clemence@example.com"
      subject.core_induction_programme_id = core_induction_programme.id
      subject.school_id = school.id

      subject.save!
      school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)

      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(1)
    end
  end

  describe "opt_out?" do
    it "returns true when induction programme choice is 'no_early_career_teachers'" do
      subject.induction_programme_choice = "no_early_career_teachers"
      expect(subject.opt_out?).to be_truthy
    end

    it "returns true when induction programme choice is 'design_our_own'" do
      subject.induction_programme_choice = "design_our_own"
      expect(subject.opt_out?).to be_truthy
    end

    it "returns false when induction programme choice is 'core_induction_programme'" do
      subject.induction_programme_choice = "core_induction_programme"
      expect(subject.opt_out?).to be_falsey
    end

    it "returns false when induction programme choice is nil" do
      expect(subject.opt_out?).to be_falsey
    end
  end

  describe "opt_out!" do
    context "when no school cohort for 2020 exists" do
      before do
        subject.core_induction_programme_id = core_induction_programme.id
        subject.school_id = school.id
      end

      it "creates the school cohort, and sets programme choice to 'no_early_career_teachers'" do
        subject.opt_out!
        school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)
        expect(school_cohort.no_early_career_teachers?).to be_truthy
      end
    end

    context "school cohort for 2020 exists" do
      before do
        subject.core_induction_programme_id = core_induction_programme.id
        subject.school_id = school.id
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")
      end

      it "creates the school cohort, and sets programme choice to 'no_early_career_teachers'" do
        subject.opt_out!
        school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)
        expect(school_cohort.no_early_career_teachers?).to be_truthy
      end
    end
  end
end
