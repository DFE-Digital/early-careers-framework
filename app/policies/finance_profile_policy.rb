# frozen_string_literal: true

class FinanceProfilePolicy < ApplicationPolicy
  def index?
    !!user&.finance?
  end

  def show?
    !!user&.finance?
  end

  def view_statements?
    user.finance_profile.product_team_user? ||
      user.finance_profile.commercial_user?
  end

  def view_payment_schedules?
    user.finance_profile.product_team_user? ||
      user.finance_profile.commercial_user?
  end

  def view_participant_data?
    user.finance_profile.support_user? ||
      user.finance_profile.product_team_user? ||
      user.finance_profile.commercial_user?
  end

  def view_duplicate_records?
    user.finance_profile.product_team_user? ||
      user.finance_profile.commercial_user?
  end

  def change_lead_provider?
    user.finance_profile.product_team_user? ||
      user.finance_profile.commercial_user?
  end

  def change_training_status?
    change_lead_provider?
  end

  class Scope < Scope
    def resolve
      return scope.all if user.finance?

      scope.none
    end
  end
end
