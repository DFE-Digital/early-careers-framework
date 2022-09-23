# frozen_string_literal: true

module DeliveryPartners
  class UpdateUserForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :delivery_partner_profile
    attribute :full_name
    attribute :email
    attribute :delivery_partner_id

    validates :delivery_partner_profile, presence: true
    validates :delivery_partner_id, presence: { message: I18n.t("errors.delivery_partner.blank") }
    validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
    validates :email, presence: { message: I18n.t("errors.email.blank") }
    validates :email, notify_email: true, allow_blank: true
    validate :email_not_taken

    delegate :user, to: :delivery_partner_profile

    def initialize(*args)
      super
      self.full_name = user.full_name
      self.email = user.email
      self.delivery_partner_id = delivery_partner_profile.delivery_partner_id
    end

    def update(attrs)
      assign_attributes(attrs)
      return false unless valid?

      user.update!(
        full_name:,
        email:,
      )

      delivery_partner_profile.update!(
        delivery_partner_id:,
      )

      true
    end

    delegate :id, to: :delivery_partner_profile

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
