# frozen_string_literal: true

class CoreInductionProgrammePolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    admin_only
  end

  def show?
    ect_has_access_to_cip?
  end
end

private

def ect_has_access_to_cip?
  if @user&.core_induction_programme == @record
    true
  else
    admin_only
  end
end
