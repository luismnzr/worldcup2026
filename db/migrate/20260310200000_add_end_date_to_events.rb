class AddEndDateToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :end_date, :date
  end
end
