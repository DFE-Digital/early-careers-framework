# frozen_string_literal: true

[2020, 2021, 2022].each { |y| FactoryBot.create(:seed_cohort, start_year: y) }
