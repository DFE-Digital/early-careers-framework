# frozen_string_literal: true

FactoryBot.create(:seed_user, full_name: "Administrator", email: "admin@example.com").tap do |admin_user|
  FactoryBot.create(:seed_admin_profile, user: admin_user)
end
