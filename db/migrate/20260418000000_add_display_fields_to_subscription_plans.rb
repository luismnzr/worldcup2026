class AddDisplayFieldsToSubscriptionPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :subscription_plans, :featured, :boolean, default: false, null: false
    add_column :subscription_plans, :sort_order, :integer, default: 0, null: false
    add_column :subscription_plans, :features, :text
    add_column :subscription_plans, :badge_label, :string

    add_index :subscription_plans, :sort_order
  end
end
