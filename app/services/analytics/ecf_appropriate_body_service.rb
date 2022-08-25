# frozen_string_literal: true

module Analytics
  class ECFAppropriateBodyService
    class << self
      def upsert_record(appropriate_body)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFAppropriateBody.find_or_initialize_by(appropriate_body_id: appropriate_body.id)
        record.appropriate_body_id = appropriate_body.id
        record.name = appropriate_body.name
        record.body_type = appropriate_body.body_type

        record.created_at = appropriate_body.created_at
        record.updated_at = appropriate_body.updated_at

        record.save!
      end
    end
  end
end
