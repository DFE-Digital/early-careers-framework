# frozen_string_literal: true

module Admin::Participants::NPQ
  class ChangeFullNameForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :user

    attribute :full_name, :string

    validates :full_name, presence: true, length: { maximum: 128 }

    def initialize(user, full_name: nil)
      @user = user

      super(full_name:)
    end

    def save
      return unless valid?

      user.update!(full_name:)
    end
  end
end
