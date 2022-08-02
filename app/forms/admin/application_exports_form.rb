# frozen_string_literal: true

module Admin
  class ApplicationExportsForm < BaseForm
    attr_reader :start_date, :end_date, :npq_application_export
    attr_accessor :user

    def self.permitted_params
      %i[
        start_date
        end_date
      ]
    end

    validate :validate_start_date
    validate :validate_start_date_in_the_past
    validates :start_date, presence: true

    validate :validate_end_date
    validate :validate_end_date_in_the_past
    validates :end_date, presence: true

    validate :validate_sensible_dates
    validate :validate_start_date_after_relaunch_date

    validates :user, presence: true
    validate :validate_user_is_admin

    def save
      return false unless valid?

      @npq_application_export = ::NPQApplications::Export.create!(
        start_date:,
        end_date:,
        user:,
      )

      true
    end

    def start_date=(value)
      @start_date_invalid = false
      @start_date = ActiveRecord::Type::Date.new.cast(value)
    rescue StandardError => _e
      @start_date_invalid = true
    end

    def end_date=(value)
      @end_date_invalid = false
      @end_date = ActiveRecord::Type::Date.new.cast(value)
    rescue StandardError => _e
      @end_date_invalid = true
    end

  private

    def validate_end_date_in_the_past
      errors.add(:end_date, :in_future) if end_date && (end_date > Time.zone.now)
    end

    def validate_end_date
      errors.add(:end_date, :invalid) if @end_date_invalid
    end

    def validate_start_date_in_the_past
      errors.add(:start_date, :in_future) if start_date && (start_date > Time.zone.now)
    end

    def validate_start_date
      errors.add(:start_date, :invalid) if @start_date_invalid
    end

    def validate_sensible_dates
      return if start_date.blank? || end_date.blank?

      errors.add(:end_date, :before_start_date) if start_date > end_date
    end

    def validate_user_is_admin
      errors.add(:user, :not_admin) unless user.admin?
    end

    def validate_start_date_after_relaunch_date
      return if start_date.blank?

      if start_date < Date.new(2022, 6, 6)
        errors.add(:start_date, :before_relaunch_date)
      end
    end
  end
end
