class PopulatePrivateChildcareProviderIdInApplications < ActiveRecord::Migration[7.0]
  def up
    # Use SQL to update the school_id column based on school_urn
    execute <<-SQL
      UPDATE applications
      SET private_childcare_provider_id = private_childcare_providers.id
      FROM private_childcare_providers
      WHERE applications.private_childcare_provider_urn = private_childcare_providers.provider_urn
    SQL
  end

  def down; end
end
