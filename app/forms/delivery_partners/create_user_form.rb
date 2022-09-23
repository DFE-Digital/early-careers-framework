# frozen_string_literal: true

module DeliveryPartners
  class CreateUserForm
    include ActiveModel::Model

    attr_accessor :full_name, :email, :delivery_partner_id

    validates :delivery_partner_id, presence: { message: I18n.t("errors.delivery_partner.blank") }
    validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
    validates :email, presence: { message: I18n.t("errors.email.blank") }
    validates :email, notify_email: true, allow_blank: true
    validate :email_not_taken

    def delivery_partner
      @delivery_partner ||= DeliveryPartner.find(delivery_partner_id)
    end

    def save
      return false unless valid?

      DeliveryPartnerProfile.create_delivery_partner_user(full_name, email, delivery_partner)
      true
    end

  private

    def email_not_taken
      return if delivery_partner_id.blank?
      return unless (user = Identity.find_user_by(email:))

      if DeliveryPartnerProfile.where(user:, delivery_partner:).exists?
        errors.add(:email, :unique, message: I18n.t("errors.email.taken"))
      end
    end
  end
end
