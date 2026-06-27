class AddPriceToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :price, :decimal, precision: 10, scale: 2
  end
end
