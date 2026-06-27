class AddWellhubControlsToClassTemplates < ActiveRecord::Migration[7.2]
  def change
    add_column :class_templates, :wellhub_enabled, :boolean, default: true, null: false
    add_column :class_templates, :wellhub_spot_limit, :integer
  end
end
