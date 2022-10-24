# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::CipInfo, type: :component do
  let(:school) { FactoryBot.create :school }
  let(:programme) { FactoryBot.create :core_induction_programme }
  let(:school_cohort) { FactoryBot.create :school_cohort, :cip, school:, core_induction_programme: programme }

  subject! do
    with_request_url "/schools/test-school" do
      render_inline(described_class.new(school_cohort:, school:))
    end
  end

  it "has the correct content" do
    with_request_url "/schools/test-school" do
      expect(rendered_content).to have_content "Use the DfE accredited materials"
      expect(rendered_content).to have_content programme.name
    end
  end

  context "when a block is passed in" do
    let(:block_content) { "extra content" }

    subject! do
      with_request_url "/schools/test-school" do
        render_inline(described_class.new(school_cohort:, school:)) do
          block_content
        end
      end
    end

    it "renders the block" do
      expect(rendered_content).to have_content(block_content)
    end
  end
end
