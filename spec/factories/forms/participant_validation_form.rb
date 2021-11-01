# frozen_string_literal: true

FactoryBot.define do
  factory :participant_validation_form, class: Participants::ParticipantValidationForm do
    transient do
      participant_profile { create :participant_profile, :ecf }
      steps { nil }
    end

    participant_profile_id { participant_profile.id }

    build_with do
      byebug
    end

    # to_create do |instance|
    #   if (existing = Cohort.find_by(start_year: instance.start_year))
    #     instance.attributes = existing.attributes
    #     instance.instance_variable_set("@new_record", false)
    #   else
    #     instance.save!
    #   end
    # end
    #
    # start_year { Faker::Number.unique.between(from: 2021, to: 2100) }
    #
    # trait :current do
    #   start_year { 2021 }
    # end
  end
end
