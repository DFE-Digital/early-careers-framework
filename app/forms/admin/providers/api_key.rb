module Admin
  module Providers
    class ApiKey
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Serialization

      attribute :id
      attribute :use_vault, :boolean

      class << self
        def from(provider)
          new(id: provider.id, use_vault: provider.use_vault?)
        end
      end
    end
  end
end
