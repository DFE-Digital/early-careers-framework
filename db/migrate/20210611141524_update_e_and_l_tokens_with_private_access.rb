# frozen_string_literal: true

class UpdateEAndLTokensWithPrivateAccess < ActiveRecord::Migration[6.1]
  def up
    EngageAndLearnApiToken.update_all(private_api_access: true)
  end

  def down
    EngageAndLearnApiToken.update_all(private_api_access: false)
  end
end
