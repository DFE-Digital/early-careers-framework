# frozen_string_literal: true

RSpec.describe Schools::Year2020Form, type: :model do
  let!(:school) { create :school }
  let!(:cohort) { create :cohort, start_year: 2020 }
  let!(:induction_coordinator) { create :user, :induction_coordinator }
  let!(:core_induction_programme) { create :core_induction_programme }
  let!(:default_schedule) { create(:schedule, name: "ECF September standard 2021") }
  let!(:name) { Faker::Name.name }
  let!(:email) { Faker::Internet.email }

  subject { described_class.new(school_id: school.id) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:core_induction_programme_id).on(:choose_cip) }
    it { is_expected.to validate_presence_of(:full_name).on(:create_teacher).with_message("Enter a full name for your teacher") }
    it { is_expected.to validate_presence_of(:email).on(:create_teacher).with_message("Enter an email address for your teacher") }

    it "validates that the email address is not already in use by an ECT" do
      create(:participant_profile, :ect, user: create(:user, email: email))
      form = Schools::Year2020Form.new(full_name: name, email: email)
      expect(form).not_to be_valid
      expect(form.errors[:email].first).to eq("This email address is already in use")
      expect(form.email_already_taken?).to be_truthy
    end
  end

  describe "save!" do
    it "creates a school cohort and user when given all details" do
      subject.core_induction_programme_id = core_induction_programme.id
      add_new_participant(subject)

      subject.save!
      school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)

      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(1)
    end

    it "works with multiple participants" do
      allow(EarlyCareerTeachers::Create).to receive(:call).and_call_original

      subject.core_induction_programme_id = core_induction_programme.id

      test_participants = build_list(:user, 3)
      test_participants.each { |participant| add_new_participant(subject, name: participant.full_name, email: participant.email) }

      subject.save!
      school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)
      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(3)

      test_participants.each do |participant|
        expect(EarlyCareerTeachers::Create).to have_received(:call).with(
          full_name: participant.full_name,
          email: participant.email,
          school_cohort: school_cohort,
          mentor_profile_id: nil,
        )
      end
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
    before do
      subject.induction_programme_choice = %w[no_early_career_teachers design_our_own].sample
    end

    context "when no school cohort for 2020 exists" do
      it "creates school cohort, and sets programme choice to induction_programme_choice value" do
        subject.opt_out!
        school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)
        expect(school_cohort.induction_programme_choice).to eq(subject.induction_programme_choice)
      end
    end

    context "school cohort for 2020 exists" do
      before do
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "core_induction_programme")
      end

      it "creates the school cohort, and sets programme choice to 'no_early_career_teachers'" do
        subject.opt_out!
        school_cohort = SchoolCohort.find_by(school: school, cohort: cohort)
        expect(school_cohort.induction_programme_choice).to eq(subject.induction_programme_choice)
      end
    end
  end

  describe "store_new_participant" do
    it "adds participant with email and full_name from the form to its participants" do
      subject.full_name = "Joe Bloggs"
      subject.email = "joe@example.com"

      subject.store_new_participant

      form_participant = subject.get_participant(1)
      expect(form_participant[:full_name]).to eq("Joe Bloggs")
      expect(form_participant[:email]).to eq("joe@example.com")
    end
  end

  describe "remove_participant" do
    it "removes participant with particular index" do
      subject.store_new_participant
      subject.remove_participant(1)
      expect(subject.get_participant(1)).to be_nil
    end

    it "removes participant with particular index" do
      subject.store_new_participant
      subject.store_new_participant
      subject.store_new_participant
      subject.remove_participant(1)
      expect(subject.get_participant(1)).to be_nil
      expect(subject.get_participant(2)).not_to be_nil
      expect(subject.get_participant(3)).not_to be_nil
    end
  end

  describe "new_participant_index" do
    it "returns 1 when no participants" do
      expect(subject.new_participant_index).to eq(1)
    end

    it "returns 1 more than max of participant indexes" do
      subject.store_new_participant
      subject.store_new_participant
      subject.store_new_participant

      expect(subject.new_participant_index).to eq(4)
    end

    it "returns 1 more than max of participant indexes even with gaps in the middle" do
      subject.store_new_participant
      subject.store_new_participant
      subject.remove_participant(1)
      subject.store_new_participant

      expect(subject.new_participant_index).to eq(4)
    end

    it "reuses removed index if it was the max index" do
      subject.store_new_participant
      subject.store_new_participant
      subject.remove_participant(2)

      expect(subject.new_participant_index).to eq(2)
    end
  end

private

  def add_new_participant(form, name: Faker::Name.name, email: Faker::Internet.email)
    form.full_name = name
    form.email = email
    form.store_new_participant
  end
end
