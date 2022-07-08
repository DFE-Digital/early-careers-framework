# frozen_string_literal: true

class NPQApplicationExport < ApplicationRecord
  belongs_to :user

  def perform_later
    Admin::ApplicationExportJob.perform_later(self)
  end
end
