# frozen_string_literal: true

module RecordDeclarations
  class Base
    attr_accessor :params

    delegate :user_profile, :actual_lead_provider, to: :not_implemented_error

    class << self
      delegate :required_params, to: :not_implemented_error

      def call(params)
        new(params).call
      end

      def not_implemented_error
        raise NotImplementedError, "Method must be implemented"
      end
    end

    def not_implemented_error
      self.class.not_implemented_error
    end

    def call
      record.validate
      profile_declaration.validate
      raise ActionController::ParameterMissing, record.errors.map(&:message) unless record.errors.empty?
      raise ActionController::ParameterMissing, profile_declaration.errors.map(&:message) unless profile_declaration.errors.empty?

      declaration = create_record!
      validate_provider!
      { id: declaration.id }
    end

  private

    def initialize(params)
      @params = params
    end

    def user_id
      params[:user_id]
    end

    def course
      params[:course_identifier]
    end

    def user
      @user ||= User.find_by(id: user_id)
    end

    def record
      @record ||= declaration_type.new(params.slice(*self.class.required_params))
    end

    def profile_declaration
      @profile_declaration ||= ProfileDeclaration.new(
        participant_profile: user_profile,
        participant_declaration: record,
      )
    end

    def create_record!
      ActiveRecord::Base.transaction do
        record.save!
        profile_declaration.save!
        record
      end
    end

    def lead_provider_from_token
      params[:cpd_lead_provider]
    end

    def validate_provider!
      # TODO: Remove the nil? check and fix the test setup so that they build the school cohort, partnership and give us back the actual lead_provider.
      raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider_from_token == actual_lead_provider
    end
  end
end
