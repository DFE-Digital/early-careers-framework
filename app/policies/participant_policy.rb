# frozen_string_literal: true

class ParticipantPolicy < UserPolicy
  def index?
    return true if admin_only
    return @record.all? { |participant| user_can_access?(participant) } if user.induction_coordinator?
  end

  def show?
    return true if admin_only
    return user_can_access?(@record) if user.induction_coordinator?
  end

  alias_method :edit_details?, :show?
  alias_method :update_details?, :show?
  alias_method :edit_mentor?, :show?
  alias_method :update_mentor?, :show?

private

  def user_can_access?(participant)
    return false unless participant.participant?

    user.schools.include?(participant.school)
  end
end
