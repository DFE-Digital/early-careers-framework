module Finance
  module ECF
    class Duplicate < ApplicationRecord
      self.table_name = "ecf_duplicates"
      self.primary_key = "id"
      belongs_to :master_duplicate, class_name: "Finance::ECF::Duplicate", foreign_key: :master_participant_profile_id
      belongs_to :latest_induction_record, class_name: "InductionRecord"

      def master_profile?
        participant_profile_status == 1
      end
    end
  end
end
