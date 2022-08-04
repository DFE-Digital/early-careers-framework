# frozen_string_literal: true

module NPQApplications
  class Export < ApplicationRecord
    self.table_name = "npq_application_exports"

    belongs_to :user, inverse_of: :npq_application_exports

    scope :new_to_old, -> { order(created_at: :desc) }

    def perform_later
      Admin::NPQApplications::ExportJob.perform_later(self)
    end
  end
end
