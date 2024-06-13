# frozen_string_literal: true

# The following section creates some records that Delivery Partners can use to
# familiarise themselves with the school user interface.
if Rails.env.in?(%w[development staging review])
  delivery_partner_credentials = {
    "Ambition Institute" => "ambition-institute-sit-%d-%d-%d@example.com",
    "Best Practice Network" => "best-practice-network-sit-%d-%d-%d@example.com",
    "Church of England" => "church-of-england-sit-%d-%d-%d@example.com",
    "Education Development Trust" => "education-development-trust-sit-%d-%d-%d@example.com",
    "LLSE" => "leadership-learning-south-east-sit-%d-%d-%d@example.com",
    "National Institute of Teaching" => "niot-sit-%d-%d-%d@example.com",
    "School-Led Network" => "school-led-network-sit-%d-%d-%d@example.com",
    "Teach First" => "teach-first-sit-%d-%d-%d@example.com",
    "Teacher Development Trust" => "teacher-development-trust-sit-%d-%d-%d@example.com",
    "UCL Institute of Education" => "ucl-sit-%d-%d-%d@example.com",
  }

  delivery_partner_credentials.each do |name, email|
    delivery_partner = FactoryBot.create(:seed_delivery_partner, name: "#{name} Delivery Partner")

    [Cohort.previous, Cohort.current, Cohort.next].each do |cohort|
      [1, 2].each do |i|
        NewSeeds::Scenarios::Schools::School
          .new(name: "#{name} Test School #{i} #{cohort.start_year}", urn: rand(100_000..999_999).to_s)
          .build
          .with_partnership_in(cohort:, delivery_partner:)
          .with_an_induction_tutor(full_name: "#{name} Test SIT #{i} #{cohort.start_year}", email: email % [Array.wrap(i), cohort.start_year, 0].flatten)
          .with_school_cohort_and_programme(cohort:, programme_type: :fip)

        # Independent school GIAS 10
        school = NewSeeds::Scenarios::Schools::School
          .new(name: "#{name} Test School #{i} #{cohort.start_year} independent gias type 10", urn: rand(100_000..999_999).to_s)
          .build
          .with_partnership_in(cohort:, delivery_partner:)
          .with_an_induction_tutor(full_name: "#{name} Test SIT #{i} #{cohort.start_year} school type 10", email: email % [Array.wrap(i), cohort.start_year, 10].flatten)
          .with_school_cohort_and_programme(cohort:, programme_type: :fip)
        school.school.update!(school_type_code: 10)

        # Independent school GIAS 11
        school = NewSeeds::Scenarios::Schools::School
                   .new(name: "#{name} Test School #{i} #{cohort.start_year} independent gias type 11", urn: rand(100_000..999_999).to_s)
                   .build
                   .with_partnership_in(cohort:, delivery_partner:)
                   .with_an_induction_tutor(full_name: "#{name} Test SIT #{i} #{cohort.start_year} 11", email: email % [Array.wrap(i), cohort.start_year, 11].flatten)
                   .with_school_cohort_and_programme(cohort:, programme_type: :fip)
        school.school.update!(school_type_code: 11)

        # British school overseas GIAS 37
        school = NewSeeds::Scenarios::Schools::School
                   .new(name: "#{name} Test School #{i} #{cohort.start_year} independent gias type 37", urn: rand(100_000..999_999).to_s)
                   .build
                   .with_partnership_in(cohort:, delivery_partner:)
                   .with_an_induction_tutor(full_name: "#{name} Test SIT #{i} #{cohort.start_year} 37", email: email % [Array.wrap(i), cohort.start_year, 37].flatten)
                   .with_school_cohort_and_programme(cohort:, programme_type: :fip)
        school.school.update!(school_type_code: 37)
      end
    end
  end
end
