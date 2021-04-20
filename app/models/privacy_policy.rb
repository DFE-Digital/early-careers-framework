# frozen_string_literal: true

class PrivacyPolicy < ApplicationRecord
  class Acceptance < ApplicationRecord
    self.table_name = :privacy_policy_acceptances

    belongs_to :user
    belongs_to :privacy_policy
  end

  def self.current
    order(:major_version, :minor_version).last
  end

  def acceptance_required?(user)
    return false if !user || user.admin?
    return false unless user.induction_coordinator_profile

    !Acceptance
      .joins(:privacy_policy)
      .where(user: user)
      .where("privacy_policies.major_version >= ?", major_version)
      .exists?
  end

  def version
    [major_version, minor_version].join(".")
  end

  def accept!(user)
    Acceptance.create(
      user: user,
      privacy_policy: self,
    )
  end
end
