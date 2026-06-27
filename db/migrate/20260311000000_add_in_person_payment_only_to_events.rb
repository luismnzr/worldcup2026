class AddInPersonPaymentOnlyToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :in_person_payment_only, :boolean, default: false, null: false
  end
end
