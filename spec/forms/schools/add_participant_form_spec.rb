# frozen_string_literal: true

RSpec.describe Schools::AddParticipantForm, type: :model do
  let(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, cohort: cohort_2021) }
  let(:school) { school_cohort.school }
  let(:user) { create :user }
  let!(:dqt_response) do
    {
      trn: "1234567",
      full_name: "Danny DeVito",
      nino: "AB 12 34 56 D",
      dob: Date.new(1990, 1, 1),
      config: {},
    }
  end

  subject(:form) { described_class.new(current_user_id: user.id, school_cohort_id: school_cohort.id) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:trn).on(:trn).with_message("Enter the teacher reference number (TRN)") }
  it { is_expected.to validate_presence_of(:date_of_birth).on(:dob) }
  it { is_expected.to validate_presence_of(:nino).on(:nino).with_message("Enter the national insurance number (NINo)") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }
  it { is_expected.to validate_presence_of(:start_date).on(:start_date) }
  it { is_expected.to validate_presence_of(:transfer).on(:transfer) }

  describe "start_date validation" do
    it "permits dates from 1/9/2021" do
      form.start_date = Date.new(2021, 9, 1)
      expect(form.valid?(:start_date)).to be true
    end

    it "permits dates up to 1 year from now" do
      form.start_date = Date.current + 1.year
      expect(form.valid?(:start_date)).to be true
    end

    it "does not permit a date prior to 1/9/2021" do
      form.start_date = Date.new(2021, 8, 31)
      expect(form.valid?(:start_date)).to be false
      expect(form.errors[:start_date]).to be_present
    end

    it "does not permit a date more that 1 year in the future" do
      form.start_date = Date.current + 1.year + 1.day
      expect(form.valid?(:start_date)).to be false
      expect(form.errors[:start_date]).to be_present
    end
  end

  describe "when a record matches the validation data" do
    before do
      form.trn = "1234567"
      form.date_of_birth = Date.new(1990, 1, 1)
      form.full_name = "Danny DeVito"
      allow(ParticipantValidationService).to receive(:validate).and_return(dqt_response)
    end

    it "returns a response from the dqt" do
      form.complete_step(:dob, date_of_birth: form.date_of_birth)
      expect(form.dqt_record).to eq(dqt_response)
    end
  end

  describe "mentor_options" do
    it "does not include mentors with withdrawn records" do
      create(:ecf_schedule, cohort: cohort_2021)
      withdrawn_mentor_record = create(:mentor, :withdrawn_record, school_cohort:).user

      expect(form.mentor_options).not_to include(withdrawn_mentor_record)
    end

    it "includes active mentors" do
      create(:ecf_schedule, cohort: cohort_2021)
      active_mentor_record = create(:mentor, school_cohort:).user

      expect(form.mentor_options).to include(active_mentor_record)
    end

    context "when multiple cohorts are active" do
      let(:cohort_2022) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
      let(:school_cohort_2) { create(:school_cohort, school:, cohort: cohort_2022) }

      context "when there are mentors in the school mentor pool" do
        let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
        let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: school_cohort_2) }

        before do
          Mentors::AddToSchool.call(school:, mentor_profile:)
          Mentors::AddToSchool.call(school:, mentor_profile: mentor_profile_2)
        end

        it "includes to mentors in the pool" do
          expect(form.mentor_options).to match_array [mentor_profile.user, mentor_profile_2.user]
        end
      end

      context "when there are no mentors in the school mentor pool" do
        it "does not return any mentors" do
          expect(form.mentor_options).to be_empty
        end
      end
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
      let(:teacher_profile) { create(:teacher_profile, user:) }
      let!(:ect_profile) { create(:ect_participant_profile, teacher_profile:) }

      it "returns true" do
        expect(form).to be_email_already_taken
      end

      context "when the ECT profile record is withdrawn" do
        let!(:ect_profile) { create(:ect_participant_profile, :withdrawn_record, teacher_profile:) }

        it "returns false" do
          expect(form).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a Mentor" do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user:) }
      let!(:mentor_profile) { create(:mentor_participant_profile, teacher_profile:) }

      it "returns true" do
        expect(form).to be_email_already_taken
      end

      context "when the mentor profile record is withdrawn" do
        let!(:mentor_profile) { create(:mentor_participant_profile, :withdrawn_record, teacher_profile:) }

        it "returns false" do
          expect(form).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a NPQ registrant", :with_default_schedules do
      let(:user) { create(:user, email: "ray.clemence@example.com") }
      let(:teacher_profile) { create(:teacher_profile, user:) }
      let!(:npq_profile) { create(:npq_participant_profile, teacher_profile:) }

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
        create(:mentor_participant_profile, user:)
      end

      it "returns false" do
        expect(form.can_add_self?).to be false
      end
    end

    context "when the user is a mentor at this school" do
      before do
        create(:mentor_participant_profile, user:, school_cohort:)
      end

      it "returns false" do
        expect(form.can_add_self?).to be false
      end
    end
  end

  describe "#display_name" do
    it "returns your" do
      form.assign_attributes(type: :self)
      expect(form.display_name).to eql("your")
    end

    it "returns the name of the participant who's being added" do
      form.assign_attributes(type: :mentor, full_name: user.full_name)
      expect(form.display_name).to eql("#{user.full_name}’s")
    end
  end

  describe "#save!" do
    before do
      response = {
        trn: form.trn,
        full_name: form.full_name,
        nino: form.formatted_nino,
        date_of_birth: form.date_of_birth,
        config: {},
      }

      form.type = %i[ect mentor].sample
      form.full_name = Faker::Name.name
      form.email = Faker::Internet.email
      form.trn = "1234567"
      form.date_of_birth = Date.new(1990, 1, 1)
      form.nino = "AB123456D"
      form.start_date = Date.new(2022, 9, 1)
      form.dqt_record = dqt_response
      form.mentor_id = (form.mentor_options.pluck(:id) + %w[later]).sample if form.type == :ect
      allow(ParticipantValidationService).to receive(:validate).and_return(response)

      create :ecf_schedule
    end

    context "Participant has been added" do
      before do
        allow(ParticipantMailer).to receive(:participant_added).and_call_original
        allow(ParticipantMailer).to receive(:sit_has_added_and_validated_participant).and_call_original
      end

      context "When participant details validated against the DQT" do
        it "creates new participant record" do
          expect { form.save! }.to change(ParticipantProfile::ECF, :count).by 1
        end

        it "creates new validation data" do
          expect { form.save! }.to change(ECFParticipantValidationData, :count).by 1
        end

        it "sends a participant the added and validated" do
          form.save!
          profile = ECFParticipantValidationData.find_by(trn: form.trn).participant_profile
          expect(ParticipantMailer).not_to have_received(:participant_added)
          expect(ParticipantMailer).to have_received(:sit_has_added_and_validated_participant)
                                         .with(participant_profile: profile, school_name: school_cohort.school.name)
        end
      end

      context "A SIT is adding themselves as a mentor and type is not self" do
        it "does not send the SIT an email saying they have been added and validated" do
          create(:induction_coordinator_profile, user:)
          form.save!
          expect(ParticipantMailer).not_to have_received(:sit_has_added_and_validated_participant)
        end
      end

      context "A SIT is adding themselves as a mentor and type is set to self" do
        it "does not send the SIT an email saying they have been added and validated" do
          form.type = :self
          form.save!
          expect(ParticipantMailer).not_to have_received(:sit_has_added_and_validated_participant)
        end
      end
    end
  end

  describe "sit_adding_themselves?" do
    it "returns true when type is set to self" do
      form.type = :self
      expect(form.sit_adding_themselves?).to be true
    end

    it "returns false when type is not self" do
      form.type = :mentor
      expect(form.sit_adding_themselves?).to be false
    end
  end
end
