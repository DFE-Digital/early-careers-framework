# frozen_string_literal: true

RSpec.describe LeadProviders::YourSchools::Table, type: :view_component do
  let(:partnerships) { Kaminari.paginate_array(Array.new(rand(5..10)) { double }).page(1) }

  let(:component) { described_class.new partnerships: partnerships }

  stub_component LeadProviders::YourSchools::TableRow

  it "renders table row for each school" do
    partnerships.each do |partnership|
      expect(rendered).to have_rendered(LeadProviders::YourSchools::TableRow).with(partnership: partnership)
    end
  end
end
