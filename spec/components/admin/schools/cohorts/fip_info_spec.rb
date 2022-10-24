# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::FipInfo, type: :component do
  let(:school) { FactoryBot.create :school }
  let(:school_cohort) { FactoryBot.create(:school_cohort, :fip, school:) }
  let(:lead_provider) { FactoryBot.create :lead_provider }

  before do
    FactoryBot.create(
      :partnership,
      school: school_cohort.school,
      cohort: school_cohort.cohort,
      lead_provider:,
    )
  end

  subject! do
    with_request_url "/schools/test-school" do
      render_inline(described_class.new(school_cohort:))
    end
  end

  it "has the correct content" do
    expect(rendered_content).to have_content "Use an approved training provider"
    expect(rendered_content).to have_content lead_provider.name
    expect(rendered_content).to have_content school_cohort.delivery_partner.name
  end

  context "when a block is passed in" do
    let(:block_content) { "extra content" }

    subject! do
      with_request_url "/schools/test-school" do
        render_inline(described_class.new(school_cohort:)) do
          block_content
        end
      end
    end

    it "renders the block" do
      expect(rendered_content).to have_content(block_content)
    end
  end
end
