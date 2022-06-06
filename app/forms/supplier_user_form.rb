# frozen_string_literal: true

class SupplierUserForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :full_name, :email, :supplier

  validates :supplier, presence: { message: I18n.t("errors.supplier.blank") }, on: :supplier
  validates :full_name, presence: { message: I18n.t("errors.name.blank") }, on: :details
  validates :email,
            presence: { message: I18n.t("errors.supplier_email.blank") },
            notify_email: true,
            on: :details
  validate :email_not_taken, on: :details

  def attributes
    { full_name: nil, email: nil, supplier: nil }
  end

  def chosen_supplier
    LeadProvider.find_by(id: supplier)
  end

  def save!
    LeadProviderProfile.create_lead_provider_user(
      full_name,
      email,
      chosen_supplier,
      Rails.application.routes.url_helpers.root_url(
        host: Rails.application.config.domain,
        **UTMService.email(:new_lead_provider),
      ),
    )
  end

private

  def email_not_taken
    errors.add(:email, :unique, message: I18n.t("errors.supplier_email.taken")) if Identity.find_user_by(email:)
  end
end
