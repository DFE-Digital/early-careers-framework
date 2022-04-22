# frozen_string_literal: true

RSpec.describe Schools::AddParticipantForm, type: :model do
  let(:school_cohort) { create :school_cohort }
  let(:user) { create :user }
  let!(:dqt_response) do
    {
      trn: "1234567",
      full_name: "Danny DeVito",
      nino: nil,
      dob: Date.new(1990, 1, 1),
      config: {},
    }
  end

  subject(:form) { described_class.new(current_user_id: user.id, school_cohort_id: school_cohort.id) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }
  it { is_expected.to validate_presence_of(:do_you_know_teachers_trn).on(:do_you_know_teachers_trn).with_message("Select whether you know the teacher reference number (TRN) for the teacher you are adding") }
  it { is_expected.to validate_presence_of(:start_date).on(:start_date) }

  describe "when a SIT knows the teachers trn" do
    it { is_expected.to validate_presence_of(:trn).on(:trn).with_message("Enter the teacher reference number (TRN) for the teacher you are adding") }
    it { is_expected.to validate_presence_of(:do_you_know_teachers_trn).on(:do_you_know_teachers_trn).with_message("Select whether you know the teacher reference number (TRN) for the teacher you are adding") }
    it { is_expected.to validate_presence_of(:dob).on(:dob) }

    before do
      form.trn = "1234567"
      form.dob = Date.new(1990, 1, 1)
      form.full_name = "Danny DeVito"
      allow(ParticipantValidationService).to receive(:validate).and_return(dqt_response)
    end

    it "returns a response from the dqt when a record matches" do
      form.complete_step(:dob, dob: form.dob)
      expect(form.dqt_record).to eq(dqt_response)
    end
  end

  describe "mentor_options" do
    it "does not include mentors with withdrawn records" do
      withdrawn_mentor_record = create(:mentor_participant_profile, :withdrawn_record, school_cohort: school_cohort).user

      expect(form.mentor_options).not_to include(withdrawn_mentor_record)
    end

    it "includes active mentors" do
      active_mentor_record = create(:mentor_participant_profile, school_cohort: school_cohort).user

      expect(form.mentor_options).to include(active_mentor_record)
    end
  end

  describe "email_already_taken?" do
    before do
      form.email = "ray.clemence@example.com"
    end

    context "when the email is not already in use" do
      it "returns false" do
        expect(form).not_to be_email_already_taken
      end
    end

    context "when the email is in use by an ECT user" do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user: user) }
      let!(:ect_profile) { create(:ect_participant_profile, teacher_profile: teacher_profile) }

      it "returns true" do
        expect(form).to be_email_already_taken
      end

      context "when the ECT profile record is withdrawn" do
        let!(:ect_profile) { create(:ect_participant_profile, :withdrawn_record, teacher_profile: teacher_profile) }

        it "returns false" do
          expect(form).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a Mentor" do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user: user) }
      let!(:mentor_profile) { create(:mentor_participant_profile, teacher_profile: teacher_profile) }

      it "returns true" do
        expect(form).to be_email_already_taken
      end

      context "when the mentor profile record is withdrawn" do
        let!(:mentor_profile) { create(:mentor_participant_profile, :withdrawn_record, teacher_profile: teacher_profile) }

        it "returns false" do
          expect(form).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a NPQ registrant" do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user: user) }
      let!(:npq_profile) { create(:npq_participant_profile, teacher_profile: teacher_profile) }

      it "returns false" do
        expect(form).not_to be_email_already_taken
      end
    end
  end

  describe "can_add_self?" do
    context "when the user is not a mentor" do
      it "returns true" do
        expect(form.can_add_self?).to be true
      end
    end

    context "when the user is a mentor at another school" do
      before do
        create(:mentor_participant_profile, user: user)
      end

      it "returns false" do
        expect(form.can_add_self?).to be false
      end
    end

    context "when the user is a mentor at this school" do
      before do
        create(:mentor_participant_profile, user: user, school_cohort: school_cohort)
      end

      it "returns false" do
        expect(form.can_add_self?).to be false
      end
    end
  end

  describe "start_term_legend" do
    before do
      form.full_name = "John Doe"
    end

    context "when the user is not a mentor" do
      before do
        form.participant_type = :ect
      end

      it "returns the right legend" do
        expect(form.start_term_legend).to eq(I18n.t("schools.participants.add.start_term.ect", full_name: "John Doe"))
      end
    end

    context "when the user is a mentor" do
      before do
        form.participant_type = :mentor
      end

      it "returns the right string" do
        expect(form.start_term_legend).to eq(I18n.t("schools.participants.add.start_term.mentor", full_name: "John Doe"))
      end
    end
  end

  describe "#trn_known?" do
    before do
      form.do_you_know_teachers_trn = "true"
    end

    it "returns true" do
      expect(form.trn_known?).to be true
    end
  end

  describe "#save!" do
    before do
      response = {
        trn: form.trn,
        full_name: form.full_name,
        nino: nil,
        dob: form.dob,
        config: {},
      }

      form.type = form.type_options.sample
      form.full_name = Faker::Name.name
      form.email = Faker::Internet.email
      form.trn = "1234567"
      form.dob = Date.new(1990, 1, 1)
      form.start_term = "autumn_2021"
      form.start_date = Date.new(2022, 9, 1)
      form.dqt_record = dqt_response
      form.mentor_id = (form.mentor_options.pluck(:id) + %w[later]).sample if form.type == :ect
      allow(ParticipantValidationService).to receive(:validate).and_return(response)

      create :ecf_schedule
    end

    it "creates new participant record" do
      expect { form.save! }.to change(ParticipantProfile::ECF, :count).by 1
    end

    it "creates new validation data" do
      expect { form.save! }.to change(ECFParticipantValidationData, :count).by 1
    end

    context "no dqt record is present" do
      it "does not create ecf validation data" do
        form.dqt_record = nil
        expect { form.save! }.not_to change(ECFParticipantValidationData, :count)
      end
    end
  end
end
