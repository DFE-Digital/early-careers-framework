# frozen_string_literal: true

RSpec.describe Schools::AddParticipantForm, type: :model do
  let(:school_cohort) { create :school_cohort }
  let(:user) { create :user }

  subject(:form) { described_class.new(current_user_id: user.id, school_cohort_id: school_cohort.id) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }

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

  describe "#save!" do
    before do
      form.type = form.type_options.sample
      form.full_name = Faker::Name.name
      form.email = Faker::Internet.email
      form.start_term = "Autumn 2021"
      form.mentor_id = (form.mentor_options.pluck(:id) + %w[later]).sample if form.type == :ect

      create :ecf_schedule
    end

    it "creates new participant record" do
      expect { form.save! }.to change(ParticipantProfile::ECF, :count).by 1
    end
  end
end
