# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to have_many(:mentee_participant_declarations).class_name("ParticipantDeclaration").with_foreign_key(:mentor_user_id) }
    it { is_expected.to have_many(:participant_profiles) }
    it { is_expected.to have_one(:admin_profile) }
    it { is_expected.to have_one(:finance_profile) }
    it { is_expected.to have_many(:delivery_partner_profiles) }
    it { is_expected.to have_many(:appropriate_body_profiles) }
    it { is_expected.to have_one(:induction_coordinator_profile) }
    it { is_expected.to have_many(:schools).through(:induction_coordinator_profile) }
    it { is_expected.to have_one(:lead_provider_profile) }
    it { is_expected.to have_one(:lead_provider).through(:lead_provider_profile) }
    it { is_expected.to have_one(:early_career_teacher_profile) }

    describe "early_career_teacher_profile" do
      it "returns an active profile" do
        user = create(:ect_participant_profile).user
        expect(user.early_career_teacher_profile).to be_an_instance_of ParticipantProfile::ECT
      end

      it "returns nil when there is no active profile" do
        user = create(:ect_participant_profile, :withdrawn_record).user
        expect(user.early_career_teacher_profile).to be_nil
      end
    end

    describe "mentor_profile" do
      it "returns an active profile" do
        user = create(:mentor_participant_profile).user
        expect(user.mentor_profile).to be_an_instance_of ParticipantProfile::Mentor
      end

      it "returns nil when there is no active profile" do
        user = create(:mentor_participant_profile, :withdrawn_record).user

        expect(user.mentor_profile).to be_nil
      end
    end
  end

  describe "scopes" do
    describe "#full_name_matches" do
      it "adds a case-insensitive wildcarded condition on full name" do
        expect(described_class.full_name_matches("xyz").to_sql).to include("users.full_name ilike '%xyz%'")
      end
    end

    describe "#email_matches" do
      it "adds a wildcarded condition on email" do
        # we don't need to worry about case sensitivity here because the email
        # address column is citext
        expect(described_class.email_matches("xyz").to_sql).to include("users.email like '%xyz%'")
      end
    end
  end

  describe "whitespace stripping" do
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
    it { is_expected.to validate_presence_of(:email).with_message("Enter an email address") }
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

  describe "after_update" do
    context "when the email changes" do
      let(:user) { create(:user, email: "mary.lewis@example.com") }

      context "when there are no identity records for the user" do
        it "does not generate an error" do
          expect {
            user.update!(email: "mary.jones@example.com")
          }.not_to raise_error
        end
      end

      context "when the user is a participant" do
        let!(:mentor_profile) { create(:mentor, user:) }

        context "when an original participant identity exists" do
          before do
            user.update!(email: "mary.jones@example.com")
          end

          it "updates the original identity email" do
            expect(user.participant_identities.original.first.email).to eq user.email
          end

          context "when more than 1 identity exists" do
            let!(:identity2) { create(:participant_identity, email: "mjones@somemail.com") }

            before do
              identity2.update!(user:)
              user.participant_identities.original.first.update!(email: "m.jones@example.com")
            end

            it "does not update the original identity email" do
              expect(user.participant_identities.original.first.email).not_to eq user.email
            end
          end
        end

        context "when there are transferred identity records" do
          let(:identity2) { create(:participant_identity, :npq, email: "mary.e.jones@example.com") }

          before do
            identity2.update!(user:)
            user.update!(email: "mary.jones@example.com")
          end

          it "does not update the email on the transferred records" do
            expect(identity2.email).to eq("mary.e.jones@example.com")
          end
        end
      end
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
      user = create(:ect_participant_profile).user

      expect(user.early_career_teacher?).to be true
    end

    it "is expected to be false when the user does not have an early career teacher profile" do
      user = create(:user)

      expect(user.early_career_teacher?).to be false
    end

    it "is false when the ect profile is withdrawn" do
      user = create(:ect_participant_profile, :withdrawn_record).user
      expect(user.early_career_teacher?).to be false
    end
  end

  describe "#mentor?" do
    it "is expected to be true when the user has a mentor profile" do
      user = create(:mentor_participant_profile).user

      expect(user.mentor?).to be true
    end

    it "is expected to be false when the user does not have a mentor profile" do
      user = create(:user)

      expect(user.mentor?).to be false
    end

    it "is false when the mentor profile is withdrawn" do
      user = create(:mentor_participant_profile, :withdrawn_record).user
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
      cip = create(:core_induction_programme)
      user = create(:mentor_participant_profile, core_induction_programme: cip).user

      expect(user.core_induction_programme).to eq cip
    end

    it "is expected to return ect cip for ect users" do
      cip = create(:core_induction_programme)
      user = create(:ect_participant_profile, core_induction_programme: cip).user

      expect(user.core_induction_programme).to eq cip
    end

    it "is expected to return nil when no cip" do
      user = create(:user)
      expect(user.core_induction_programme).to be_nil
    end
  end

  describe "#school" do
    it "is expected to return mentor school for mentor users" do
      school = create(:school)
      school_cohort = create(:school_cohort, school:)
      user = create(:mentor_participant_profile, school_cohort:).user

      expect(user.school).to eq school
    end

    it "is expected to return ect school for ect users" do
      school = create(:school)
      school_cohort = create(:school_cohort, school:)
      user = create(:ect_participant_profile, school_cohort:).user

      expect(user.school).to eq school
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

      it { is_expected.to include user }
      it { is_expected.to include old_user }
    end

    context "with a user that was just updated" do
      let!(:user) { create(:user, updated_at: 1.hour.ago) }
      let!(:old_user) { create(:user, updated_at: 1.hour.ago) }

      before { user.touch }

      subject { User.changed_since(10.minutes.ago) }

      it { is_expected.to include user }
      it { is_expected.to_not include old_user }
    end

    context "with a user that has been updated less than a second after the given timestamp" do
      let(:timestamp) { 5.minutes.ago }
      let(:user) { create(:user, updated_at: timestamp + 0.001.seconds) }

      subject { User.changed_since(timestamp) }

      it { is_expected.to include user }
    end

    context "with a user that has been updated exactly at the given timestamp" do
      let(:timestamp) { 10.minutes.ago }
      let(:user) { create(:user, updated_at: timestamp) }

      subject { User.changed_since(timestamp) }

      it { is_expected.to_not include user }
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
      subject(:user) { create(:ect_participant_profile).user }

      it "returns Early career teacher" do
        expect(user.user_description).to eq("Early career teacher")
      end
    end

    context "when the user is a mentor" do
      subject(:user) { create(:mentor_participant_profile).user }

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

  describe "#user_roles" do
    it "returns delivery_partner role" do
      expect(create(:user, :delivery_partner).user_roles).to eq(%w[delivery_partner])
    end

    it "returns lead_prpvider role" do
      expect(create(:user, :lead_provider).user_roles).to eq(%w[lead_provider])
    end

    it "returns appropriate_body role" do
      expect(create(:user, :appropriate_body).user_roles).to eq(%w[appropriate_body])
    end

    it "returns admin role" do
      expect(build(:user, :admin).user_roles).to eq(%w[admin])
    end

    it "returns finance role" do
      expect(build(:user, :finance).user_roles).to eq(%w[finance])
    end

    it "returns induction_coordinator role" do
      expect(build(:user, :induction_coordinator).user_roles).to eq(%w[induction_coordinator])
    end

    it "returns early career teacher role" do
      expect(create(:user, :early_career_teacher).user_roles).to match_array(%w[early_career_teacher])
    end

    it "returns mentor role" do
      expect(create(:user, :mentor).user_roles).to eq(%w[mentor])
    end

    it "returns npq_participant role" do
      expect(create(:user, :npq).user_roles).to eq(%w[npq_participant])
    end

    it "returns npq_applicant role" do
      expect(create(:seed_npq_application, :valid).user.user_roles).to eq(%w[npq_applicant])
    end

    it "returns induction_coordinator and mentor roles" do
      expect(create(:user, :mentor, :induction_coordinator).user_roles).to match_array(%w[induction_coordinator mentor])
    end

    it "returns induction_coordinator and delivery_partner roles" do
      expect(create(:user, :induction_coordinator, :delivery_partner).user_roles).to match_array(%w[delivery_partner induction_coordinator])
    end

    it "returns mentor, induction_coordinator and delivery_partner roles" do
      expect(create(:user, :mentor, :induction_coordinator, :delivery_partner).user_roles).to match_array(%w[delivery_partner induction_coordinator mentor])
    end
  end

  context "when archiving users" do
    let(:email) { "user@example.org" }
    let(:archived_email) { nil }
    let(:user) { create(:user, :teacher, email:, archived_email:) }

    describe "#archive!" do
      before do
        user
        Timecop.freeze
      end

      after do
        Timecop.return
      end

      it "changes user email" do
        expect {
          user.archive!
        }.to change(user, :email).from(email).to("user#{user.id}@example.org")
      end

      it "saves user email to archived_email column" do
        expect {
          user.archive!
        }.to change(user, :archived_email).from(nil).to(email)
      end

      it "saves timestamp to archived_at column" do
        user.archive!
        expect(user.archived_at).to be_within(2.seconds).of(Time.zone.now)
      end
    end

    describe "#archived?" do
      context "when archived_email is empty" do
        it "returns false" do
          expect(user.archived?).to eq(false)
        end
      end

      context "when archived_email is not empty" do
        let(:archived_email) { "foo@bar.com" }

        it "returns true" do
          expect(user.archived?).to eq(true)
        end
      end
    end
  end
end
