# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::CipInfo, type: :view_component do
  let(:school) { create(:school, slug: "test-school") }
  let(:school_cohort) { FactoryBot.create :school_cohort, :cip, school:, core_induction_programme: programme }
  let(:programme) { FactoryBot.create :core_induction_programme }

  component { described_class.new school_cohort: }

  it "has the correct content" do
    with_request_url "/schools/test-school" do
      expect(rendered).to have_content "Use the DfE accredited materials"
      expect(rendered).to have_content programme.name
    end
  end

  context "when no programme is selected" do
    let(:programme) { nil }

    it "renders" do
      with_request_url "/schools/test-school" do
        expect(rendered).to render
      end
    end
  end
end
