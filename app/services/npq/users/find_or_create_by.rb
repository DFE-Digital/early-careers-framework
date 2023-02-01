# frozen_string_literal: true

module NPQ
  module Users
    class FindOrCreateBy
      attr_reader :email, :get_an_identity_id, :full_name

      def initialize(params:)
        @email = params[:email]
        @get_an_identity_id = params[:get_an_identity_id]
        @full_name = params[:full_name]
      end

      def call
        return missing_email_error_response if email.blank?

        response = existing_user_by_get_an_identity_id ||
          existing_user_by_email ||
          create_new_user

        if response.user.present?
          response.user.update!(full_name:)
        end

        response
      end

    private

      # Attempts to find a user matching the get_an_identity_id
      #
      # Returns an error if a user is found but the email address is taken by a different user
      # Otherwise returns the found user, updating the email address if necessary
      def existing_user_by_get_an_identity_id
        return if get_an_identity_id.blank?
        return if user_with_get_an_identity_id.blank?

        if user_with_email.present?
          if user_with_email == user_with_get_an_identity_id
            return OpenStruct.new(user: user_with_get_an_identity_id)
          else
            return user_with_get_an_identity_id_different_to_user_with_email_response
          end
        end

        user_with_get_an_identity_id.update!(email:)
        OpenStruct.new(user: user_with_get_an_identity_id)
      end

      # Attempts to find a user matching the email address
      #
      # Returns an error if the user already has a different get an identity ID
      # Otherwise returns the found user, updating the get an identity ID if necessary
      def existing_user_by_email
        return if user_with_email.blank?

        if get_an_identity_id.blank?
          return OpenStruct.new(user: user_with_email) if user_with_email.get_an_identity_id.blank?

          return email_lookup_failed_as_matching_get_an_identity_id_not_sent_response
        end

        update_get_an_identity_id_on_user_with_email
      end

      def update_get_an_identity_id_on_user_with_email
        if user_with_email.get_an_identity_id.present?
          return OpenStruct.new(user: user_with_email) if user_with_email.get_an_identity_id == get_an_identity_id

          return user_with_email_has_different_get_an_identity_id_response
        end

        user_with_email.update!(get_an_identity_id:)
        OpenStruct.new(user: user_with_email)
      end

      def create_new_user
        return new_user_save_errors_response unless new_user.save

        OpenStruct.new(user: new_user, new_user: true)
      end

      def user_with_get_an_identity_id
        @user_with_get_an_identity_id ||= Identity.find_user_by(get_an_identity_id:)
      end

      def user_with_email
        @user_with_email ||= Identity.find_user_by(email:)
      end

      def new_user
        @new_user ||= User.new(email:, get_an_identity_id:, full_name:)
      end

      def email_lookup_failed_as_matching_get_an_identity_id_not_sent_response
        error = user_with_email.errors.add(:email, :lookup_failed_as_matching_get_an_identity_id_not_sent)
        OpenStruct.new(error:)
      end

      def user_with_get_an_identity_id_different_to_user_with_email_response
        error = user_with_email.errors.add(:email, :user_with_get_an_identity_id_different_to_user_with_email_response)
        OpenStruct.new(error:)
      end

      def user_with_email_has_different_get_an_identity_id_response
        error = user_with_email.errors.add(:get_an_identity_id, :user_with_email_already_has_different_get_an_identity_id)
        OpenStruct.new(error:)
      end

      def new_user_save_errors_response
        OpenStruct.new(errors: new_user.errors.map(&:itself))
      end

      def missing_email_error_response
        OpenStruct.new(error: OpenStruct.new(attribute: :email, message: "is required"))
      end
    end
  end
end
