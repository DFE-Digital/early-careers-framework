# frozen_string_literal: true

module Finance
  module ECF
    class Duplicate < ApplicationRecord
      self.table_name = "ecf_duplicates"
      self.primary_key = "id"
      belongs_to :primary_duplicate, class_name: "Finance::ECF::Duplicate", foreign_key: :primary_participant_profile_id
      belongs_to :latest_induction_record, class_name: "InductionRecord"
      has_many :duplicate_participant_profiles, -> { where("id != primary_participant_profile_id") }, class_name: "Finance::ECF::Duplicate", foreign_key: :primary_participant_profile_id
      has_many :induction_records, foreign_key: :participant_profile_id
      belongs_to :user

      scope :primary_profiles, -> { where("id = primary_participant_profile_id") }
      scope :duplicate_profiles, -> { where("id != primary_participant_profile_id") }
      has_many :participant_declarations, foreign_key: :participant_profile_id

      def primary_profile?
        participant_profile_status == 1
      end
    end
  end
end
