class PrivacyPolicy < ApplicationRecord
  class Acceptance < ApplicationRecord
    self.table_name = :privacy_policy_acceptances

    belongs_to :user
    belongs_to :privacy_policy
  end

  def self.current
    order(Arel.sql "string_to_array(version, '.')::int[] desc").first
  end

  def self.acceptance_required?(user)
    return false if !user || user.admin?
    return false unless user.induction_coordinator_profile

    !current_policy_accepted?(user)
  end

  def self.current_policy_accepted?(user)
    Acceptance
      .joins(:privacy_policy)
      .where(user: user)
      .where("privacy_policies.version LIKE ?", "#{current.major_version}.%")
      .exists?
  end

  def major_version
    version.split(".").first
  end

  def accept!(user)
    Acceptance.create(
      user: user,
      privacy_policy: self
    )
  end
end
