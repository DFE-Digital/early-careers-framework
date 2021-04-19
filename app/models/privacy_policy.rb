class PrivacyPolicy < ApplicationRecord
  def self.current
    order(Arel.sql "string_to_array(version, '.')::int[] desc").first
  end
end
