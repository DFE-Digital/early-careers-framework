# frozen_string_literal: true

module NPQApplications
  class EligibilityImport < ApplicationRecord
    self.table_name = "npq_application_eligibility_imports"

    belongs_to :user, inverse_of: :npq_application_eligibility_imports

    validates :filename, presence: { message: "Filename can't be blank" }

    validates :status, presence: true

    validates :user, presence: true
    validate :validate_user_is_admin

    enum status: {
      pending: "pending",
      processing: "processing",
      completed: "completed",
      completed_with_errors: "completed_with_errors",
      failed: "failed",
    }

    scope :new_to_old, -> { order(created_at: :desc) }

    def perform_later
      Admin::NPQApplications::EligibilityImportJob.perform_later(self)
    end

    def processed?
      completed? || failed? || completed_with_errors?
    end

    def begin_processing!
      update(status: :processing)
    end

    def complete!
      new_status = import_errors.present? ? :completed_with_errors : :completed
      update!(status: new_status, processed_at: Time.current)
    end

    def fail!
      update(status: :failed, processed_at: Time.current)
    end

  private

    def validate_user_is_admin
      errors.add(:user, :not_admin) unless user.admin?
    end
  end
end
