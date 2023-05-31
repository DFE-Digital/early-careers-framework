# frozen_string_literal: true

# The following section creates some records that Delivery Partners can use to
# familiarise themselves with the school user interface.
if Rails.env.in?(%w[development deployed_development])
  delivery_partner_credentials = {
    "Ambition Institute" => "ambition-institute-sit-%d@example.com",
    "Best Practice Network" => "best-practice-network-sit-%d@example.com",
    "Church of England" => "church-of-england-sit-%d@example.com",
    "Education Development Trust" => "education-development-trust-sit-%d@example.com",
    "Leadership Learning South East" => "leadership-learning-south-east-sit-%d@example.com",
    "National Institute of Teaching" => "niot-sit-%d@example.com",
    "School-Led Network" => "school-led-network-sit-%d@example.com",
    "Teach First" => "teach-first-sit-%d@example.com",
    "Teacher Development Trust" => "teacher-development-trust-sit-%d@example.com",
    "UCL Institute of Education" => "ucl-sit-%d@example.com",
  }

  cohort = Cohort.current

  delivery_partner_credentials.each do |name, email|
    delivery_partner = FactoryBot.create(:seed_delivery_partner, name: "#{name} Delivery Partner")

    [1, 2].each do |i|
      NewSeeds::Scenarios::Schools::School
        .new(name: "#{name} Test School #{i}")
        .build
        .with_partnership_in(cohort:, delivery_partner:)
        .with_an_induction_tutor(full_name: "#{name} Test SIT #{i}", email: email % Array.wrap(i))
        .with_school_cohort_and_programme(cohort:, programme_type: :fip)
    end
  end
end
