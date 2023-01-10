# frozen_string_literal: true

RSpec.describe Schools::Year2020Form, type: :model do
  let!(:school) { create :school }
  let!(:cohort_2020) { Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) }
  let!(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:core_induction_programme) { create :core_induction_programme }
  let!(:default_schedule) { create(:ecf_schedule, cohort: cohort_2021) }
  let!(:name) { Faker::Name.name }
  let!(:email) { Faker::Internet.email }

  subject { described_class.new(school_id: school.id) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:core_induction_programme_id).on(:choose_cip) }
    it { is_expected.to validate_presence_of(:full_name).on(:create_teacher).with_message("Enter a full name for your teacher") }
    it { is_expected.to validate_presence_of(:email).on(:create_teacher).with_message("Enter an email address for your teacher") }

    it "validates that the email address is not already in use by an ECT" do
      create(:ect_participant_profile, user: create(:user, email:))
      form = Schools::Year2020Form.new(full_name: name, email:)
      expect(form).not_to be_valid(:create_teacher)
      expect(form.errors[:email].first).to eq("This email address is already in use")
      expect(form.email_already_taken?).to be_truthy
    end
  end

  describe "save!" do
    it "creates a school cohort and user when given all details" do
      subject.core_induction_programme_id = core_induction_programme.id
      add_new_participant(subject)

      subject.save!
      school_cohort = SchoolCohort.find_by(school:, cohort: cohort_2020)

      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(1)
    end

    it "works with multiple participants" do
      allow(EarlyCareerTeachers::Create).to receive(:call).and_call_original

      subject.core_induction_programme_id = core_induction_programme.id

      test_participants = build_list(:user, 3)
      test_participants.each { |participant| add_new_participant(subject, name: participant.full_name, email: participant.email) }

      subject.save!
      school_cohort = SchoolCohort.find_by(school:, cohort: cohort_2020)
      expect(school_cohort).not_to be_nil
      expect(school_cohort.ecf_participants.count).to eq(3)

      test_participants.each do |participant|
        expect(EarlyCareerTeachers::Create).to have_received(:call).with(
          full_name: participant.full_name,
          email: participant.email,
          school_cohort:,
          mentor_profile_id: nil,
          year_2020: true,
        )
      end
    end

    it "emails a user a confirmation email of 2020 cohort ECTs" do
      test_participants = build_list(:user, 3)
      test_participants.each do |participant|
        add_new_participant(subject, name: participant.full_name, email: participant.email)
      end

      subject.core_induction_programme_id = core_induction_programme.id

      expect {
        subject.save!
      }.to have_enqueued_mail(SchoolMailer, :year2020_add_participants_confirmation)
        .with(
          recipient: school.contact_email,
          school_name: school.name,
          teacher_name_list: test_participants.map { |p| "- #{p.full_name}" }.join("\n"),
        )
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
