# frozen_string_literal: true

module AppropriateBodies
  class UpdateUserForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :appropriate_body_profile
    attribute :full_name
    attribute :email
    attribute :appropriate_body_id

    validates :appropriate_body_profile, presence: true
    validates :appropriate_body_id, presence: { message: I18n.t("errors.appropriate_body.blank") }
    validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
    validates :email, presence: { message: I18n.t("errors.email.blank") }
    validates :email, notify_email: true, allow_blank: true
    validate :email_not_taken

    delegate :user, to: :appropriate_body_profile

    def initialize(*args)
      super
      self.full_name = user.full_name
      self.email = user.email
      self.appropriate_body_id = appropriate_body_profile.appropriate_body_id
    end

    def update(attrs)
      assign_attributes(attrs)
      return false unless valid?

      user.update!(
        full_name:,
        email:,
      )

      appropriate_body_profile.update!(
        appropriate_body_id:,
      )

      true
    end

    delegate :id, to: :appropriate_body_profile

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
