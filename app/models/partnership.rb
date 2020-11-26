class Partnership < ApplicationRecord
  belongs_to :school
  belongs_to :lead_provider

  def confirmed?
    !confirmed.nil?
  end

  def confirm
    self.confirmed = Date.current
    save!
  end
end
