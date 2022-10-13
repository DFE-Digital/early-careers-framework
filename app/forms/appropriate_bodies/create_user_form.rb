# frozen_string_literal: true

module AppropriateBodies
  class CreateUserForm
    include ActiveModel::Model

    attr_accessor :full_name, :email, :appropriate_body_id

    validates :appropriate_body_id, presence: { message: I18n.t("errors.appropriate_body.blank") }
    validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }
    validates :email, presence: { message: I18n.t("errors.email.blank") }
    validates :email, notify_email: true, allow_blank: true
    validate :email_not_taken

    def appropriate_body
      @appropriate_body ||= AppropriateBody.find(appropriate_body_id)
    end

    def save
      return false unless valid?

      AppropriateBodyProfile.create_appropriate_body_user(full_name, email, appropriate_body)
      true
    end

  private

    def email_not_taken
      return if appropriate_body_id.blank?
      return unless (user = Identity.find_user_by(email:))

      if AppropriateBodyProfile.where(user:, appropriate_body:).exists?
        errors.add(:email, :unique, message: I18n.t("errors.email.taken"))
      end
    end
  end
end
