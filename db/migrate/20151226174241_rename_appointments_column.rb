class RenameAppointmentsColumn < ActiveRecord::Migration
  
  def change
    rename_column :appointments, :end, :end_date
    rename_column :appointments, :start, :start_date
  end

end
