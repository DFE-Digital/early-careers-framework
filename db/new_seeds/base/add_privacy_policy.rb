# frozen_string_literal: true

FactoryBot.create(
  :seed_privacy_policy,
  html: Rails.root.join("data/privacy_policy.html").read,
  major_version: 1,
  minor_version: 0,
)
