# frozen_string_literal: true

class ChooseRoleForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  USER_ROLES = {
    "delivery_partner" => "Delivery partner",
    "admin" => "DfE admin",
    "finance" => "DfE Finance",
    "induction_coordinator" => "Induction tutor",
    "induction_coordinator_and_mentor" => "Induction tutor and mentor",
    "teacher" => "Teacher",
  }.freeze

  attribute :user
  attribute :role

  validates :role, inclusion: { in: :role_values }

  def role_options
    USER_ROLES.slice(*user.user_roles)
  end

  def redirect_path(helpers:)
    case role
    when "change_role"
      helpers.contact_support_choose_role_path
    when "admin"
      helpers.admin_schools_path
    when "finance"
      helpers.finance_landing_page_path
    when "delivery_partner"
      helpers.delivery_partners_participants_path
    when "induction_coordinator_and_mentor"
      helpers.induction_coordinator_mentor_path(user)
    when "induction_coordinator"
      helpers.induction_coordinator_dashboard_path(user)
    when "teacher"
      helpers.participant_start_path(user)
    when "no_role"
      helpers.dashboard_path
    end
  end

  def only_one_role?
    return false unless user.user_roles.count == 1

    self.role = user.user_roles.first
    true
  end

  def has_no_role?
    return false unless user.user_roles.count == 0

    self.role = "no_role"
    true
  end

private

  def role_values
    role_options.keys << "change_role"
  end
end
