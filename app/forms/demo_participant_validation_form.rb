# frozen_string_literal: true

class DemoParticipantValidationForm
  include ActiveModel::Model

  attr_accessor :full_name, :nino, :trn, :dob

  validates :full_name, presence: true
  validates :dob, presence: true
  validates :trn, presence: true
end
