# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to have_many(:participant_profiles) }
    it { is_expected.to have_one(:admin_profile) }
    it { is_expected.to have_one(:finance_profile) }
    it { is_expected.to have_one(:induction_coordinator_profile) }
    it { is_expected.to have_many(:schools).through(:induction_coordinator_profile) }
    it { is_expected.to have_one(:lead_provider_profile) }
    it { is_expected.to have_one(:lead_provider).through(:lead_provider_profile) }
    it { is_expected.to have_one(:early_career_teacher_profile) }

    describe "early_career_teacher_profile" do
      it "returns an active profile" do
        user = create(:user, :early_career_teacher)
        expect(user.early_career_teacher_profile).to be_an_instance_of ParticipantProfile::ECT
      end

      it "returns nil when there is no active profile" do
        user = create(:participant_profile, :ect, status: "withdrawn").user
        expect(user.early_career_teacher_profile).to be_nil
      end
    end

    describe "mentor_profile" do
      it "returns an active profile" do
        user = create(:user, :mentor)
        expect(user.mentor_profile).to be_an_instance_of ParticipantProfile::Mentor
      end

      it "returns nil when there is no active profile" do
        user = create(:participant_profile, :mentor, status: "withdrawn").user
        expect(user.mentor_profile).to be_nil
      end
    end
  end

  describe "before_validation" do
    let(:user) { build(:user, full_name: "\t  Gordon \tBanks \n", email: " \tgordo@example.com \n ") }

    it "strips whitespace from :full_name" do
      user.valid?
      expect(user.full_name).to eq "Gordon Banks"
    end

    it "strips whitespace from :email" do
      user.valid?
      expect(user.email).to eq "gordo@example.com"
    end
  end

  describe "validations" do
    subject { FactoryBot.create(:user) }
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name") }
    it { is_expected.to validate_presence_of(:email).with_message("Enter an email") }
    it {
      is_expected.to validate_uniqueness_of(:email)
                       .case_insensitive
                       .with_message("This email address is already in use")
    }

    it "rejects an invalid email" do
      user = FactoryBot.build(:user, email: "invalid@email,com")

      expect(user.valid?).to be_falsey
      expect(user.errors.messages[:email]).to match_array ["Enter an email address in the correct format, like name@example.com"]
    end
  end

  describe "#admin?" do
    it "is expected to be true when the user has an admin profile" do
      user = create(:user, :admin)

      expect(user.admin?).to be true
    end

    it "is expected to be false when the user does not have an admin profile" do
      user = create(:user)

      expect(user.admin?).to be false
    end
  end

  describe "#finance?" do
    it "is expected to be true when the user has a finance profile" do
      user = create(:user, :finance)

      expect(user.finance?).to be true
    end

    it "is expected to be false when the user does not have a finance profile" do
      user = create(:user)

      expect(user.finance?).to be false
    end
  end

  describe "#supplier_name" do
    it "returns the correct lead provider name" do
      user = create(:user, :lead_provider)

      expect(user.supplier_name).to eq user.lead_provider.name
    end

    it "returns nil when the user doesn't belong to a supplier" do
      user = create(:user)

      expect(user.supplier_name).to be_nil
    end
  end

  describe "#induction_coordinator?" do
    it "is expected to be true when the user has an induction coordinator profile" do
      user = create(:user, :induction_coordinator)

      expect(user.induction_coordinator?).to be true
    end

    it "is expected to be false when the user does not have an induction coordinator profile" do
      user = create(:user)

      expect(user.induction_coordinator?).to be false
    end
  end

  describe "#early_career_teacher?" do
    it "is expected to be true when the user has an early career teacher profile" do
      user = create(:user, :early_career_teacher)

      expect(user.early_career_teacher?).to be true
    end

    it "is expected to be false when the user does not have an early career teacher profile" do
      user = create(:user)

      expect(user.early_career_teacher?).to be false
    end

    it "is false when the ect profile is withdrawn" do
      user = create(:early_career_teacher_profile, status: "withdrawn").user
      expect(user.early_career_teacher?).to be false
    end
  end

  describe "#mentor?" do
    it "is expected to be true when the user has a mentor profile" do
      user = create(:user, :mentor)

      expect(user.mentor?).to be true
    end

    it "is expected to be false when the user does not have a mentor profile" do
      user = create(:user)

      expect(user.mentor?).to be false
    end

    it "is false when the mentor profile is withdrawn" do
      user = create(:mentor_profile, status: "withdrawn").user
      expect(user.mentor?).to be false
    end
  end

  describe "#lead_provider?" do
    it "is expected to be true when the user has a lead provider profile" do
      user = create(:user, :lead_provider)

      expect(user.lead_provider?).to be true
    end

    it "is expected to be false when the user does not have a lead provider profile" do
      user = create(:user)

      expect(user.lead_provider?).to be false
    end
  end

  describe "#core_induction_programme" do
    it "is expected to return mentor cip for mentor users" do
      user = create(:user, :mentor)
      cip = create(:core_induction_programme)
      user.mentor_profile.core_induction_programme = cip

      expect(user.core_induction_programme).to be cip
    end

    it "is expected to return ect cip for ect users" do
      user = create(:user, :early_career_teacher)
      cip = create(:core_induction_programme)
      user.early_career_teacher_profile.core_induction_programme = cip

      expect(user.core_induction_programme).to be cip
    end

    it "is expected to return nil when no cip" do
      user = create(:user)
      expect(user.core_induction_programme).to be_nil
    end
  end

  describe "#cohort" do
    it "is expected to return mentor cohort for mentor users" do
      user = create(:user, :mentor)
      cohort = create(:cohort)
      user.mentor_profile.cohort = cohort

      expect(user.cohort).to be cohort
    end

    it "is expected to return ect cohort for ect users" do
      user = create(:user, :early_career_teacher)
      cohort = create(:cohort)
      user.early_career_teacher_profile.cohort = cohort

      expect(user.cohort).to be cohort
    end

    it "is expected to return nil when no cohort" do
      user = create(:user)
      expect(user.cohort).to be_nil
    end
  end

  describe "#school" do
    it "is expected to return mentor school for mentor users" do
      user = create(:user, :mentor)
      school = create(:school)
      user.mentor_profile.school = school

      expect(user.school).to be school
    end

    it "is expected to return ect school for ect users" do
      user = create(:user, :early_career_teacher)
      school = create(:school)
      user.early_career_teacher_profile.school = school

      expect(user.school).to be school
    end

    it "is expected to return nil when no school" do
      user = create(:user)
      expect(user.school).to be_nil
    end
  end

  describe "#changed_since" do
    context "with no parameters" do
      let!(:old_user) { create(:user, updated_at: 1.hour.ago) }
      let!(:user) { create(:user, updated_at: 1.hour.ago) }

      subject { User.changed_since(nil) }

      it { should include user }
      it { should include old_user }
    end

    context "with a user that was just updated" do
      let!(:user) { create(:user, updated_at: 1.hour.ago) }
      let!(:old_user) { create(:user, updated_at: 1.hour.ago) }

      before { user.touch }

      subject { User.changed_since(10.minutes.ago) }

      it { should include user }
      it { should_not include old_user }
    end

    context "with a user that has been updated less than a second after the given timestamp" do
      let(:timestamp) { 5.minutes.ago }
      let(:user) { create(:user, updated_at: timestamp + 0.001.seconds) }

      subject { User.changed_since(timestamp) }

      it { should include user }
    end

    context "with a user that has been updated exactly at the given timestamp" do
      let(:timestamp) { 10.minutes.ago }
      let(:user) { create(:user, updated_at: timestamp) }

      subject { User.changed_since(timestamp) }

      it { should_not include user }
    end
  end

  describe "#user_description" do
    context "when the user is an admin" do
      subject(:user) { create(:user, :admin) }

      it "returns DfE admin" do
        expect(user.user_description).to eq("DfE admin")
      end
    end

    context "when the user is a finance user" do
      subject(:user) { create(:user, :finance) }

      it "returns DfE finance" do
        expect(user.user_description).to eq("DfE Finance")
      end
    end

    context "when the user is an induction tutor" do
      subject(:user) { create(:user, :induction_coordinator) }

      it "returns Induction tutor" do
        expect(user.user_description).to eq("Induction tutor")
      end
    end

    context "when the user is a lead provider" do
      subject(:user) { create(:user, :lead_provider) }

      it "returns Lead provider" do
        expect(user.user_description).to eq("Lead provider")
      end
    end

    context "when the user is an early career teacher" do
      subject(:user) { create(:user, :early_career_teacher) }

      it "returns Early career teacher" do
        expect(user.user_description).to eq("Early career teacher")
      end
    end

    context "when the user is a mentor" do
      subject(:user) { create(:user, :mentor) }

      it "returns Mentor" do
        expect(user.user_description).to eq("Mentor")
      end
    end

    context "when the user does not have an identified role" do
      subject(:user) { create(:user) }

      it "returns Unknown" do
        expect(user.user_description).to eq("Unknown")
      end
    end
  end

  describe "scope :is_ecf_participant" do
    it "includes ecf participants" do
      ect = create(:participant_profile, :ect).user
      mentor = create(:participant_profile, :mentor).user

      expect(User.is_ecf_participant).to include(ect, mentor)
    end

    it "does not include other user types" do
      admin = create(:user, :admin)
      lp = create(:user, :lead_provider)
      npq = create(:participant_profile, :npq).user

      expect(User.is_ecf_participant).not_to include(admin)
      expect(User.is_ecf_participant).not_to include(lp)
      expect(User.is_ecf_participant).not_to include(npq)
    end
  end
end
