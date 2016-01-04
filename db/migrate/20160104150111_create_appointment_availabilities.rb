class CreateAppointmentAvailabilities < ActiveRecord::Migration
  def change
    create_table :appointment_availabilities do |t|
      t.references :user, index: true, foreign_key: true
      t.date :for_date
      t.text :map

      t.timestamps null: false
    end
  end
end
