# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::Table, type: :view_component do
  let(:schools) { Kaminari.paginate_array(Array.new(rand 5..10) { double }).page(1) }
  let(:cohort) { double }

  let(:component) { described_class.new schools: schools, cohort: cohort }

  stub_component LeadProviders::YourSchools::TableRow

  it "renders table row for each school" do
    schools.each do |school|
      expect(rendered).to have_rendered(LeadProviders::YourSchools::TableRow).with(school: school, cohort: cohort)
    end
  end
end
