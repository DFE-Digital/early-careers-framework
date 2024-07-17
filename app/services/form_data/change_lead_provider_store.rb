# frozen_string_literal: true

module FormData
  class ChangeLeadProviderStore < DataStore
    def school_id
      get(:school_id)
    end

    def participant_id
      get(:participant_id)
    end

    def store_attrs(step, attrs)
      set(step, attrs)
    end

    def attrs_for(step)
      get(step) || {}
    end
  end
end
