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
        "full_induction_programme" => "Working with a DfE-funded provider",
        "school_funded_fip"        => "School-funded full induction programme",
      }.each do |training_programme, description|
        describe "training programme '#{training_programme}" do
          let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, induction_programme_choice: training_programme, school:) }

          it("has description #{description}") { expect(subject.training_programme).to eql(description) }
        end
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
  end
end
