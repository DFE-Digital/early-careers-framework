FactoryBot.define do
  factory :privacy_policy do
    sequence(:version) { |i| [(i + 2) / 2, (i + 2) % 2].join(".") }
    html { Faker::Lorem.paragraphs(number: 4).map { |para| "<p>#{para}</p>\n" } }

    to_create do |instance|
      if (existing = instance.class.find_by(version: instance.version))
        instance.attributes = existing.attributes
      else
        instance.save
      end
    end
  end
end
