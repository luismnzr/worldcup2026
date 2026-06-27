class AddUserNameToWellhubBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :wellhub_bookings, :user_name, :string
  end
end
