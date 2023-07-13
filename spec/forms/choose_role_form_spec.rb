# frozen_string_literal: true

RSpec.describe ChooseRoleForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:params) { { user:, role: form_role } }
  let(:form_role) { "" }

  describe "Single role" do
    describe "appropriate_body role" do
      let(:user) { create(:user, :appropriate_body) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[appropriate_body]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("appropriate_body")
      end

      describe "param with appropriate_body role" do
        let(:form_role) { "appropriate_body" }
        let(:helpers) { Struct.new(:appropriate_bodies_path).new("/appropriate-bodies") }

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.appropriate_bodies_path
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "delivery_partner role" do
      let(:user) { create(:user, :delivery_partner) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[delivery_partner]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("delivery_partner")
      end

      describe "param with delivery_partner role" do
        let(:form_role) { "delivery_partner" }
        let(:helpers) { Struct.new(:delivery_partners_path).new("/delivery-partners") }

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.delivery_partners_path
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "admin role" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[admin]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("admin")
      end

      describe "param with admin role" do
        let(:form_role) { "admin" }
        let(:helpers) { Struct.new(:admin_path).new("/admin") }

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.admin_path
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "finance role" do
      let(:user) { create(:user, :finance) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[finance]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("finance")
      end

      describe "param with finance role" do
        let(:form_role) { "finance" }
        let(:helpers) { Struct.new(:finance_landing_page_path).new("/finance") }

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.finance_landing_page_path
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "induction_coordinator role" do
      let(:user) { create(:user, :induction_coordinator) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[induction_coordinator]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("induction_coordinator")
      end

      describe "param with induction_coordinator role" do
        let(:form_role) { "induction_coordinator" }
        let(:helpers) do
          Struct.new(:induction_coordinator_dashboard_path) {
            def induction_coordinator_dashboard_path(_user)
              "/induction_coordinator"
            end
          }.new
        end

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.induction_coordinator_dashboard_path(user)
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "teacher role" do
      let(:user) { create(:user, :teacher) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[teacher]) }

      it "only_one_role should be true" do
        expect(form.only_one_role).to be true
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("teacher")
      end

      describe "param with teacher role" do
        let(:form_role) { "teacher" }
        let(:helpers) do
          Struct.new(:participant_start_path) {
            def participant_start_path(_user)
              "/teacher"
            end
          }.new
        end

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.participant_start_path(user)
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end
  end

  describe "Multiple roles" do
    describe "induction_coordinator and mentor roles" do
      let(:user) { create(:user, :induction_coordinator, :mentor) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[induction_coordinator_and_mentor]) }

      it "only_one_role should be false" do
        expect(form.only_one_role).to be false
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("induction_coordinator")
        expect(form.role_options).to have_key("induction_coordinator_and_mentor")
      end

      describe "param with induction_coordinator_and_mentor role" do
        let(:form_role) { "induction_coordinator_and_mentor" }
        let(:helpers) do
          Struct.new(:induction_coordinator_mentor_path) {
            def induction_coordinator_mentor_path(_user)
              "/induction_coordinator_and_mentor"
            end
          }.new
        end

        it "should be valid" do
          expect(form.valid?).to be true
        end

        it "returns correct redirect_path" do
          expect(form.redirect_path(helpers:)).to be helpers.induction_coordinator_mentor_path(user)
        end
      end

      describe "param with incorrect role" do
        let(:form_role) { "does_not_exist" }

        it "should be invalid" do
          expect(form.valid?).to be false
          expect(form.errors[:role]).to include "Choose a role"
        end
      end
    end

    describe "induction_coordinator and delivery_partner roles" do
      let(:user) { create(:user, :induction_coordinator, :delivery_partner) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[induction_coordinator delivery_partner]) }

      it "only_one_role should be false" do
        expect(form.only_one_role).to be false
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("induction_coordinator")
        expect(form.role_options).to have_key("delivery_partner")
      end
    end

    describe "teacher, induction_coordinator and delivery_partner roles" do
      let(:user) { create(:user, :teacher, :induction_coordinator, :delivery_partner) }

      it { is_expected.to validate_inclusion_of(:role).in_array(%w[teacher induction_coordinator delivery_partner]) }

      it "only_one_role should be false" do
        expect(form.only_one_role).to be false
      end

      it "has correct role_options" do
        expect(form.role_options).to have_key("teacher")
        expect(form.role_options).to have_key("induction_coordinator")
        expect(form.role_options).to have_key("delivery_partner")
      end
    end
  end

  describe "param with change_role value" do
    let(:user) { create(:user) }
    let(:form_role) { "change_role" }
    let(:helpers) { Struct.new(:contact_support_choose_role_path).new("/change_role") }

    it "should be valid" do
      expect(form.valid?).to be true
    end

    it "returns correct redirect_path" do
      expect(form.redirect_path(helpers:)).to be helpers.contact_support_choose_role_path
    end
  end

  describe "User with no roles" do
    let(:user) { create(:user) }
    let(:form_role) { "no_role" }
    let(:helpers) { Struct.new(:dashboard_path).new("/no_role") }

    it "has_no_role should be true" do
      expect(form.has_no_role).to be true
    end

    it "returns correct redirect_path" do
      expect(form.redirect_path(helpers:)).to be helpers.dashboard_path
    end
  end
end
