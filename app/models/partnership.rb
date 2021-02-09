# frozen_string_literal: true

class Partnership < ApplicationRecord
  belongs_to :school
  belongs_to :lead_provider

  def confirmed?
    confirmed_at.present?
  end

  def confirm
    self.confirmed_at = Time.zone.now
    save!
  end
end
