# frozen_string_literal: true

class EarlyCareerTeacherProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true

  include Discard::Model
  default_scope -> { kept }

  scope :kept, -> { undiscarded.joins(:user).merge(User.kept) }

  def kept?
    undiscarded? && user.kept?
  end
end
