# frozen_string_literal: true

module FormData
  class ChangeLeadProviderStore < DataStore
    def school_id
      get(:school_id)
    end

    def participant_id
      get(:participant_id)
    end

    def email
      get(:email)
    end

    def lead_provider_id
      get(:lead_provider_id)
    end

    def complete?
      get(:complete) == "true"
    end
  end
end
