# frozen_string_literal: true

class PrivacyPolicy < ApplicationRecord
  class Publish < BaseService
    SOURCE = Rails.root.join("data/privacy_policy.html")

    def initialize(major: false, logger: Rails.logger)
      @major = major
      @logger = logger
    end

    def call
      unless publishable?
        logger.info "No changes to publish - current version #{current_policy.version} is up to date"
        return
      end

      PrivacyPolicy.create!(
        html: policy_html,
        **next_version,
      )
    end

  private

    attr_reader :logger

    def major?
      @major
    end

    def policy_html
      @policy_html ||= SOURCE.read
    end

    def current_policy
      @current_policy ||= PrivacyPolicy.current
    end

    def publishable?
      return true if major? && current_policy.minor_version.positive?

      current_policy.html != policy_html
    end

    def next_version
      return { major_version: current_policy.major_version.next, minor_version: 0 } if major?

      { major_version: current_policy.major_version, minor_version: current_policy.minor_version.next }
    end
  end
end
