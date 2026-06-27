class AddWellhubSpotLimitToStudioClasses < ActiveRecord::Migration[7.2]
  def change
    add_column :studio_classes, :wellhub_spot_limit, :integer
  end
end
