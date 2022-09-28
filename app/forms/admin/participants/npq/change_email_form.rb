# frozen_string_literal: true

module Admin::Participants::NPQ
  class ChangeEmailForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attr_reader :user

    attribute :email, :string

    validates :email, presence: true, notify_email: true
    validate :email_not_taken

    def initialize(user, email: nil)
      @user = user

      super(email:)
    end

    def save
      return unless valid?

      user.update!(email:)
    end

  private

    def email_not_taken
      if Identity.find_user_by(email:).present?
        errors.add(:email, :unique, message: I18n.t("errors.email.taken"))
      end
    end
  end
end
