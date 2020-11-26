FactoryBot.define do
  factory :partnership_with_provider, class: "Partnership" do
    lead_provider { FactoryBot.create(:lead_provider) }
  end

  factory :partnership_with_school, class: "Partnership" do
    school { FactoryBot.create(:school) }
  end
end
