# frozen_string_literal: true

class ParticipantProfile::NPQPolicy < ParticipantProfilePolicy
  def show?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end
end
