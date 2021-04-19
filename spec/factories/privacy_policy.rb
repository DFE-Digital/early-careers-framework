# frozen_string_literal: true

FactoryBot.define do
  factory :privacy_policy do
    sequence(:version) { |i| [(i + 2) / 2, (i + 2) % 2].join(".") }
    html { Faker::Lorem.paragraphs(number: 4).map { |para| "<p>#{para}</p>\n" }.join }

    to_create do |instance|
      if (existing = instance.class.find_by(version: instance.version))
        instance.attributes = existing.attributes
      else
        instance.save!
      end
    end
  end

  factory :privacy_policy_acceptance do
    privacy { build :privacy_policy, version: "1.0" }
  end
end
