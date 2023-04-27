# frozen_string_literal: true

# The following section creates some records that Delivery Partners can use to
# familiarise themselves with the school user interface.
if Rails.env.in?(%w[development deployed_development])
  delivery_partner_credentials = {
    "Ambition Institute" => "ambitition-institute-sit@example.com",
  }

  cohort = Cohort.current

  delivery_partner_credentials.each do |name, email|
    delivery_partner = FactoryBot.create(:seed_delivery_partner, name: "#{name} Delivery Partner")

    NewSeeds::Scenarios::Schools::School
      .new(name: "#{name} Test School")
      .build
      .with_partnership_in(cohort:, delivery_partner:)
      .with_an_induction_tutor(full_name: "#{name} Test SIT", email:)
      .with_school_cohort_and_programme(cohort:, programme_type: :fip)
  end
end
