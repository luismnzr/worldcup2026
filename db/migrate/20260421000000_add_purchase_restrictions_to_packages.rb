class AddPurchaseRestrictionsToPackages < ActiveRecord::Migration[7.2]
  def change
    add_column :packages, :purchase_once, :boolean, null: false, default: false
    add_column :packages, :first_purchase_only, :boolean, null: false, default: false
  end
end
