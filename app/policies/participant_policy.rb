# frozen_string_literal: true

class ParticipantPolicy < ApplicationPolicy
  def index?
    admin_only
  end

  def show?
    admin_only
  end
end
