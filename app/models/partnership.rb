# frozen_string_literal: true

class Partnership < ApplicationRecord
  belongs_to :school
  belongs_to :lead_provider
  belongs_to :cohort
  belongs_to :delivery_partner
  has_many :partnership_notification_emails

  has_paper_trail
end
