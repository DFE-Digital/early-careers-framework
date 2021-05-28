# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::Table, type: :view_component do
  let(:schools) { Array.new(rand(20..25)) { |i| double("School #{i}") } }
  let(:cohort) { double "Cohort" }
  let(:page) { rand(1..2) }

  component { described_class.new schools: Kaminari.paginate_array(schools), cohort: cohort, page: page }
  request_path "/lead-providers/your-schools"

  stub_component LeadProviders::YourSchools::TableRow

  it "renders table row for each school from given page" do
    expected_schools = schools.each_slice(20).to_a[page - 1]

    expected_schools.each do |school|
      expect(rendered).to have_rendered(LeadProviders::YourSchools::TableRow).with(school: school, cohort: cohort)
    end

    (schools - expected_schools).each do |other_page_school|
      expect(rendered).not_to have_rendered(LeadProviders::YourSchools::TableRow)
        .with(hash_including(school: other_page_school))
    end
  end
end
