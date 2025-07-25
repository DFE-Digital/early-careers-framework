# frozen_string_literal: true

class ChooseRoleForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  USER_ROLES = {
    "appropriate_body" => "Appropriate body",
    "delivery_partner" => "Delivery partner",
    "lead_provider" => "Lead provider",
    "admin" => "DfE admin",
    "finance" => "DfE Finance",
    "induction_coordinator" => "Induction tutor",
  }.freeze

  attribute :user
  attribute :role

  validates :role, inclusion: { in: :role_values }

  def role_options
    USER_ROLES.slice(*sanitized_user_roles)
  end

  def redirect_path(helpers:)
    case role
    when "change_role"
      helpers.contact_support_choose_role_path
    when "admin"
      helpers.admin_path
    when "finance"
      helpers.finance_landing_page_path
    when "delivery_partner"
      helpers.delivery_partners_path
    when "appropriate_body"
      helpers.appropriate_bodies_path
    when "induction_coordinator"
      helpers.induction_coordinator_dashboard_path(user)
    when "lead_provider"
      helpers.dashboard_path
    when "no_role"
      helpers.dashboard_path
    end
  end

  def only_one_role
    return false unless sanitized_user_roles.count == 1

    self.role = sanitized_user_roles.first
    true
  end

  def has_no_role
    return false unless sanitized_user_roles.empty?

    self.role = "no_role"
    true
  end

private

  def rejected_roles
    %w[early_career_teacher mentor teacher].freeze
  end

  def sanitized_user_roles
    # allow only a SIT role and prevent other school users from seeing this
    user_roles.reject { |role| rejected_roles.include?(role) }
  end

  def user_roles
    @user_roles ||= user.user_roles
  end

  def role_values
    role_options.keys << "change_role"
  end
end
