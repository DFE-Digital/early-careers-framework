# frozen_string_literal: true

class ChangeDefaultApiTokenType < ActiveRecord::Migration[6.1]
  def change
    change_column_default :api_tokens, :type, to: "ApiToken", from: "LeadProviderApiToken"
  end
end
