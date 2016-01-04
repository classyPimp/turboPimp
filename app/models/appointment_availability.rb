class AppointmentAvailability < ActiveRecord::Base
  
  belongs_to :user


  #invoked from on_create callback from Appointment
  #finds or creates appointment
  #map contains stringified json which shall be sen to client and serialized there and used as needed
  def self.configure(appointment)
    
    a_a = self.class.where(date: appointment.start_date.strftime('%Y-%m-%d')).first_or_create
    unless a_a.map.blank?
      map = []
    else
      map = JSON.parse(a_a.map)
    end

    if map.empty?

      start_date = appointment.start_date.change(hour: 9, min: 0)
      diff = (start_date - appointment.start) / 60

      if diff > 1
        map.unshift({start_date: start_date, end_date: appointment.start_date})
      end

    else
      
      start_date = appointment.start_date
      start_date_iso = start_date.to_formatted_s(:iso8601)

      map.

    end

    if map[-1][:end_date] <= appointment.start_date.change(hour: 19, min: 0).to_formatted_s(:iso8601])

  end

end
