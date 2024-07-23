# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class StoredStep < DfE::Wizard::Step
      def save!
        store.store_attrs(key, wizard.step_params.to_h)
      end

      def stored_attrs
        store.attrs_for(key)
      end

      def key
        model_name.param_key
      end
    end
  end
end
