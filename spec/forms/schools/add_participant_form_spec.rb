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
end
