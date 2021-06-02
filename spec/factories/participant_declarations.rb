FactoryBot.define do
  factory :participant_declaration do
     early_career_teacher_profile
     lead_provider
     declaration_date { DateTime.now - 1.week }
     declaration_type { "Start" }
  end
end
