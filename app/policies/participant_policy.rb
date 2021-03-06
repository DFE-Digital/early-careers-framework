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

  def update?
    show?
  end

  alias_method :edit_name?, :edit?
  alias_method :update_name?, :update?
  alias_method :edit_email?, :edit?
  alias_method :update_email?, :update?
  alias_method :update_details?, :update?
  alias_method :edit_mentor?, :show?
  alias_method :update_mentor?, :show?

private

  def user_can_access?(participant)
    return false unless participant.participant?
    return false if participant.participant_profile.withdrawn?

    user.schools.include?(participant.school)
  end
end
