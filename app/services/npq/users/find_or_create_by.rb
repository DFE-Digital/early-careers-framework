# frozen_string_literal: true

module NPQ
  module Users
    class FindOrCreateBy
      UserResponse = Struct.new(:user, :new_user, :success, keyword_init: true)
      ErrorsResponse = Struct.new(:errors, :success, keyword_init: true)
      RecordlessError = Struct.new(:attribute, :message, :type, keyword_init: true)

      attr_reader :email, :get_an_identity_id, :full_name

      def initialize(params:)
        @email = params[:email]
        @get_an_identity_id = params[:get_an_identity_id]
        @full_name = params[:full_name]
      end

      # Returns one of two responses:
      #   1. UserResponse, which responds to:
      #        - user     : User     : A persisted User record
      #        - new_user : Boolean  : Whether user is a new record
      #        - success  : Boolean  : Always true, for use checking whether the find/create was successful
      #   2. ErrorsResponse, which responds to:
      #        - errors   : Array    : A collection of ActiveRecord::Errors and RecordlessErrors.
      #                                The latter for when the caller sends no email.
      #        - success  : Boolean  : Always false, for use checking whether the find/create was successful
      #
      def call
        return missing_email_response_with_errors if email.blank?

        response = existing_user_by_get_an_identity_id ||
          existing_user_by_email ||
          create_new_user

        if response.success
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
            return response_with_user(user_with_get_an_identity_id)
          else
            return user_with_get_an_identity_id_different_to_user_with_email_response
          end
        end

        user_with_get_an_identity_id.update!(email:)
        response_with_user(user_with_get_an_identity_id)
      end

      # Attempts to find a user matching the email address
      #
      # Returns an error if the user already has a different get an identity ID
      # Otherwise returns the found user, updating the get an identity ID if necessary
      def existing_user_by_email
        return if user_with_email.blank?

        if get_an_identity_id.blank?
          return response_with_user(user_with_email) if user_with_email.get_an_identity_id.blank?

          return email_lookup_failed_as_matching_get_an_identity_id_not_sent_response
        end

        update_get_an_identity_id_on_user_with_email
      end

      def update_get_an_identity_id_on_user_with_email
        if user_with_email.get_an_identity_id.present?
          return response_with_user(user_with_email) if user_with_email.get_an_identity_id == get_an_identity_id

          return user_with_email_has_different_get_an_identity_id_response
        end

        user_with_email.update!(get_an_identity_id:)
        response_with_user(user_with_email)
      end

      def create_new_user
        return new_user_save_errors_response unless new_user.save

        response_with_user(new_user, new_user: true)
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
        response_with_errors(
          error: user_with_email.errors.add(:email, :lookup_failed_as_matching_get_an_identity_id_not_sent),
        )
      end

      def user_with_get_an_identity_id_different_to_user_with_email_response
        response_with_errors(
          error: user_with_email.errors.add(:email, :user_with_get_an_identity_id_different_to_user_with_email_response),
        )
      end

      def user_with_email_has_different_get_an_identity_id_response
        response_with_errors(
          error: user_with_email.errors.add(:get_an_identity_id, :user_with_email_already_has_different_get_an_identity_id),
        )
      end

      def new_user_save_errors_response
        response_with_errors(errors: new_user.errors.map(&:itself))
      end

      def missing_email_response_with_errors
        response_with_errors(error: RecordlessError.new(attribute: :email, message: "is required"))
      end

      def response_with_errors(errors: [], error: nil)
        ErrorsResponse.new(errors: [errors, error].compact.flatten, success: false)
      end

      def response_with_user(user, new_user: false)
        UserResponse.new(user:, new_user:, success: true)
      end
    end
  end
end
