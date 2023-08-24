# frozen_string_literal: true

RSpec.describe Admin::Schools::PartnershipComponent, type: :component do
  let(:induction_programme_choice) { "full_induction_programme" }
  let(:school) { FactoryBot.create(:seed_school) }
  let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, :with_appropriate_body, school:, induction_programme_choice:) }
  let(:partnership) { FactoryBot.create(:seed_partnership, :valid, school:, cohort: school_cohort.cohort) }
  let(:kwargs) { { school:, school_cohort:, partnership: } }
  subject { Admin::Schools::PartnershipComponent.new(**kwargs) }

  describe "rendering" do
    before { render_inline(subject) }

    it "renders a summary list" do
      expect(rendered_content).to have_css("dl.govuk-summary-list")
    end

    it "renders a 'training programme' row" do
      expect(rendered_content).to have_css("dt", text: "Training programme")
    end

    it "renders the training programme with a change link" do
      expect(rendered_content).to have_css("dt", text: "Training programme")
      expect(rendered_content).to have_css("dd", text: "Working with a DfE-funded provider")
      expect(rendered_content).not_to have_content("Change induction programme")
    end

    context "when cip" do
      let(:induction_programme_choice) { "core_induction_programme" }

      it "renders the training programme a change link" do
        expect(rendered_content).to have_css("dd", text: "Change induction programme")
      end
    end

    it "renders the appropriate body" do
      expect(rendered_content).to have_css("dt", text: "Appropriate body")
      expect(rendered_content).to have_css("dd", text: school_cohort.appropriate_body.name)
    end

    it "renders the appropriate body" do
      expect(rendered_content).to have_css("dt", text: "Appropriate body")
      expect(rendered_content).to have_css("dd", text: school_cohort.appropriate_body.name)
    end

    it "renders the delivery partner" do
      expect(rendered_content).to have_css("dt", text: "Delivery partner")
      expect(rendered_content).to have_css("dd", text: school_cohort.delivery_partner.name)
    end

    it "renders the lead provider" do
      expect(rendered_content).to have_css("dt", text: "Lead provider")
      expect(rendered_content).to have_css("dd", text: school_cohort.lead_provider.name)
    end
  end

  describe "methods" do
    describe "#training_programme" do
      {
        "core_induction_programme" => "Using DfE-accredited materials",
        "design_our_own"           => "Designing their own training",
        "full_induction_programme" => "Working with a DfE-funded provider",
        "no_early_career_teachers" => "No ECTs this year",
        "school_funded_fip"        => "School-funded full induction programme",
      }.each do |training_programme, description|
        describe "training programme '#{training_programme}" do
          let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, induction_programme_choice: training_programme, school:) }

          it("has description #{description}") { expect(subject.training_programme).to eql(description) }
        end
      end
    end

    describe "#allow_change_programme?" do
      context "when CIP" do
        let(:induction_programme_choice) { "core_induction_programme" }

        it "allows changing of induction programme" do
          expect(subject.allow_change_programme?).to be(true)
        end
      end

      context "when FIP" do
        let(:induction_programme_choice) { "full_induction_programme" }

        context "when lead provider is present" do
          it "allows changing of induction programme" do
            expect(subject.allow_change_programme?).to be(false)
          end
        end

        context "when lead provider is nil" do
          before { allow(school_cohort).to receive(:lead_provider).and_return(nil) }

          it "allows changing of induction programme" do
            expect(subject.allow_change_programme?).to be(true)
          end
        end
      end

      context "when other" do
        let(:induction_programme_choice) { "no_early_career_teachers" }

        it "allows changing of induction programme" do
          expect(subject.allow_change_programme?).to be(true)
        end
      end
    end

    describe "#cip?" do
      let(:induction_programme_choice) { "core_induction_programme" }

      it { is_expected.to be_cip }
      it { is_expected.not_to be_fip }
      it { is_expected.not_to be_other }
    end

    describe "#fip?" do
      let(:induction_programme_choice) { "full_induction_programme" }

      it { is_expected.to be_fip }
      it { is_expected.not_to be_cip }
      it { is_expected.not_to be_other }
    end

    describe "#other?" do
      %w[design_our_own no_early_career_teachers school_funded_fip].each do |other_programme|
        context "when #{other_programme}" do
          let(:induction_programme_choice) { other_programme }

          it { is_expected.to be_other }
          it { is_expected.not_to be_fip }
          it { is_expected.not_to be_cip }
        end
      end
    end

    describe "#change_programme_href" do
      before { render_inline(subject) }

      it "is the change programme path with appropriate params" do
        expected = %(/admin/schools/#{school.slug}/cohorts/#{school_cohort.start_year}/change-programme)
        expect(subject.change_programme_href).to eql(expected)
      end
    end

    describe "#change_materials_href" do
      before { render_inline(subject) }

      it "is the change programme path with appropriate params" do
        expected = %(/admin/schools/#{school.slug}/cohorts/#{school_cohort.start_year}/change-training-materials)
        expect(subject.change_materials_href).to eql(expected)
      end
    end

    describe "#lead_provider_name" do
      it "is the lead provider's name" do
        expect(subject.lead_provider_name).to eql(school_cohort.lead_provider.name)
      end
    end

    describe "#delivery_partner" do
      it "is the delivery partner's name" do
        expect(subject.delivery_partner_name).to eql(school_cohort.delivery_partner.name)
      end
    end

    describe "#appropriate_body" do
      it "is the appropriate body's name" do
        expect(subject.appropriate_body_name).to eql(school_cohort.appropriate_body.name)
      end
    end

    describe "#materials" do
      let(:default_induction_programme) { FactoryBot.create(:seed_induction_programme, :cip, :with_school_cohort, :with_core_induction_programme, school:) }
      let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, school:, default_induction_programme:) }

      it "returns the default induction programme's core induction programme name" do
        expected = school_cohort.default_induction_programme.core_induction_programme.name
        expect(subject.materials).to eql(expected)
      end
    end
  end
end
