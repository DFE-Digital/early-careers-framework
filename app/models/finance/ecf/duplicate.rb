# frozen_string_literal: true

module Finance
  module ECF
    class Duplicate < ApplicationRecord
      self.table_name = "ecf_duplicates"
      self.primary_key = "id"
      belongs_to :master_duplicate, class_name: "Finance::ECF::Duplicate", foreign_key: :master_participant_profile_id
      belongs_to :latest_induction_record, class_name: "InductionRecord"
      has_many :duplicate_participant_profiles, -> { where("id != master_participant_profile_id") }, class_name: "Finance::ECF::Duplicate", foreign_key: :master_participant_profile_id
      has_many :induction_records, foreign_key: :participant_profile_id
      belongs_to :user, foreign_key: :participant_id

      def master_profile?
        participant_profile_status == 1
      end
    end
  end
end
