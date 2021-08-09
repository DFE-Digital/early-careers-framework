# frozen_string_literal: true

RSpec.describe Schools::AddParticipantForm, type: :model do
  let(:school_cohort) { create :school_cohort }
  let(:user) { create :user }

  subject { described_class.new(current_user_id: user.id, school_cohort_id: school_cohort.id) }

  it { is_expected.to validate_presence_of(:type).on(:type).with_message("Please select type of the new participant") }
  it { is_expected.to validate_inclusion_of(:type).in_array(subject.type_options).on(:type) }

  it { is_expected.to validate_presence_of(:full_name).on(:details) }
  it { is_expected.to validate_presence_of(:email).on(:details) }

  describe "type" do
    context "when it is set to :ect" do
      it "sets the participant_type to ect" do
        expect { subject.type = "ect" }
          .to change { subject.participant_type }.to :ect
      end
    end

    context "when it is set to :mentor" do
      it "sets the participant_type to ect" do
        expect { subject.type = "mentor" }
          .to change { subject.participant_type }.to :mentor
      end
    end

    context "when it is set to :self" do
      it "sets the participant_type to mentor as well as full name and email to match current_user details" do
        expect { subject.type = "self" }
          .to change { subject.participant_type }.to(:mentor)
          .and change { subject.full_name }.to(user.full_name)
          .and change { subject.email }.to(user.email)
      end
    end
  end

  describe "mentor_options" do
    it "does not include permanently_inactive mentors" do
      permanently_inactive_mentor = create(:participant_profile, :mentor, :permanently_inactive, school_cohort: school_cohort).user

      expect(subject.mentor_options).not_to include(permanently_inactive_mentor)
    end

    it "includes active mentors" do
      permanently_inactive_mentor = create(:participant_profile, :mentor, school_cohort: school_cohort).user

      expect(subject.mentor_options).to include(permanently_inactive_mentor)
    end
  end

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
      let!(:ect_profile) do
        create(:participant_profile, :ect, user: create(:user, email: "ray.clemence@example.com"))
      end

      it "returns true" do
        expect(subject).to be_email_already_taken
      end

      context "when the ECT is permanently_inactive" do
        let!(:ect_profile) do
          create(:participant_profile, :permanently_inactive, :ect, user: create(:user, email: "ray.clemence@example.com"))
        end

        it "returns false" do
          expect(subject).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a Mentor" do
      let!(:mentor_profile) do
        create(:participant_profile, :mentor, user: create(:user, email: "ray.clemence@example.com"))
      end

      it "returns true" do
        expect(subject).to be_email_already_taken
      end

      context "when the mentor is permanently_inactive" do
        let!(:mentor_profile) do
          create(:participant_profile, :permanently_inactive, :mentor, user: create(:user, email: "ray.clemence@example.com"))
        end

        it "returns false" do
          expect(subject).not_to be_email_already_taken
        end
      end
    end

    context "when the email is in use by a NPQ registrant" do
      before do
        existing_user = create(:user, email: "ray.clemence@example.com")
        create(:participant_profile, :npq, user: existing_user)
      end

      it "returns false" do
        expect(subject).not_to be_email_already_taken
      end
    end
  end
end
