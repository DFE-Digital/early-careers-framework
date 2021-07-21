# frozen_string_literal: true

RSpec.describe Schools::Year2020Form, type: :model do
  let!(:school) { create :school }
  let!(:cohort) { create :cohort, start_year: 2020 }
  let!(:core_induction_programme) { create :core_induction_programme }

  subject { described_class.new(school_id: school.id) }

  it { is_expected.to validate_presence_of(:full_name).on(:details) }
  it { is_expected.to validate_presence_of(:email).on(:details) }

  describe "email_already_taken?" do
    before do
      subject.email = "ray.clemence@example.com"
    end

    context "when the email is not already in use" do
      it "returns false" do
        expect(subject).not_to be_email_already_taken
      end
    end

    context "when the email is in use by an ECT user" do
      it "returns true" do
        create(:user, :early_career_teacher, email: "ray.clemence@example.com")
        expect(subject).to be_email_already_taken
      end
    end

    context "when the email is in use by a Mentor" do
      it "returns true" do
        create(:user, :mentor, email: "ray.clemence@example.com")
        expect(subject).to be_email_already_taken
      end
    end

    context "when the email is in use by a NPQ registrant" do
      it "returns false" do
        existing_user = create(:user, email: "ray.clemence@example.com")
        create(:participant_profile, :npq, user: existing_user)
        expect(subject).not_to be_email_already_taken
      end
    end
  end

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
end
