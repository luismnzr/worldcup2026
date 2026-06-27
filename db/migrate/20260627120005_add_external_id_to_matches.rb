class AddExternalIdToMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :matches, :external_id, :integer
    add_index :matches, :external_id, unique: true
  end
end
