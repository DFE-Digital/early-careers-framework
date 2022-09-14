# frozen_string_literal: true

require "finance/schedule"

FactoryBot.define do
  factory :npq_course do
    sequence(:name) { |n| "NPQ Course #{n}" }
    identifier { (Finance::Schedule::NPQLeadership::IDENTIFIERS + Finance::Schedule::NPQSpecialist::IDENTIFIERS).sample }
  end

  factory :npq_leadership_course, class: "NPQCourse" do
    sequence(:name) { |n| "NPQ Leadership Course #{n}" }
    identifier { Finance::Schedule::NPQLeadership::IDENTIFIERS.sample }
  end

  factory :npq_specialist_course, class: "NPQCourse" do
    sequence(:name) { |n| "NPQ Specialist Course #{n}" }
    identifier { Finance::Schedule::NPQSpecialist::IDENTIFIERS.sample }
  end

  factory :npq_aso_course, class: "NPQCourse" do
    sequence(:name) { |n| "NPQ ASO Course #{n}" }
    identifier { Finance::Schedule::NPQSupport::IDENTIFIERS.sample }
  end

  factory :npq_ehco_course, class: "NPQCourse" do
    sequence(:name) { |n| "NPQ EHCO Course #{n}" }
    identifier { Finance::Schedule::NPQEhco::IDENTIFIERS.sample }
  end
end
