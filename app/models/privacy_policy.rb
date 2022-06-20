# frozen_string_literal: true

class PrivacyPolicy < ApplicationRecord
  class Acceptance < ApplicationRecord
    self.table_name = :privacy_policy_acceptances

    has_paper_trail

    belongs_to :user
    belongs_to :privacy_policy
  end

  def self.current
    order(:major_version, :minor_version).last
  end

  def acceptance_required?(user)
    return false if !user || user.admin?
    return false unless user.induction_coordinator_profile || user.teacher_profile

    Acceptance
      .joins(:privacy_policy)
      .where(user:)
      .where("privacy_policies.major_version >= ?", major_version)
      .none?
  end

  def version
    [major_version, minor_version].join(".")
  end

  def accept!(user)
    Acceptance.create!(
      user:,
      privacy_policy: self,
    )
  end
end
