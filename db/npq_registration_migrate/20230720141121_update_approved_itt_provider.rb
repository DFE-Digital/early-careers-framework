class UpdateApprovedIttProvider < ActiveRecord::Migration[6.1]
  def change
    itt_provider = IttProvider.find_by(legal_name: "St Michael’s Church of England Primary School")
    itt_provider.update!(legal_name: "Christ Church Primary School Hampstead") if itt_provider.present?
  end
end
