# frozen_string_literal: true

module DeliveryPartners
  class UpdateUserForm
    include ActiveModel::Model

    attr_accessor :user, :full_name, :email, :delivery_partner_id

    validates :user, presence: true
    validates :delivery_partner_id, presence: { message: I18n.t("errors.delivery_partner.blank") }
    validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
    validates :email, presence: { message: I18n.t("errors.email.blank") }
    validates :email, notify_email: true, allow_blank: true
    validate :email_not_taken

    def initialize(user)
      @user = user
      @full_name = user.full_name
      @email = user.email
      @delivery_partner_id = user.delivery_partner_profile&.delivery_partner_id
    end

    def delivery_partner
      @delivery_partner ||= DeliveryPartner.find(delivery_partner_id)
    end

    def update(attrs)
      self.attributes = attrs

      return false unless valid?

      user.update!(
        full_name:,
        email:,
      )

      user.delivery_partner_profile.update!(
        delivery_partner:,
      )

      true
    end

    def id
      user&.id
    end

    def persisted?
      true
    end

  private

    def email_not_taken
      if User.where(email:).where.not(id: user.id).exists?
        errors.add(:email, :unique, message: I18n.t("errors.email.taken"))
      end
    end
  end
end
