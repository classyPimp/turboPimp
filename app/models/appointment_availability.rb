class AppointmentAvailability < ActiveRecord::Base
  
  belongs_to :user
  #================= PUBSUBBUS CLASS LEVEL
  #invoked from on_create callback from Appointment
  #finds or creates appointment
  #map contains stringified json which shall be sen to client and serialized there and used as needed
  def self.on_appointment_created(appointment)
    
    a_a = self.where(for_date: appointment.start_date.strftime('%Y-%m-%d')).first_or_create
    if a_a.map.blank?
      map = []
    else
      map = JSON.parse(a_a.map)
    end

    to_delete = []
    to_insert_at_start = []
    to_insert_at_end = []

    start_date = appointment.start_date.to_formatted_s(:iso8601)
    end_date = appointment.end_date.to_formatted_s(:iso8601)


    if map.empty?   
      map << start_date
      map << end_date
    else
      if map[-1] < start_date
        map << start_date
        map << end_date
      else
        0..map.length.times do |index|
          if map[index + 1] && start_date < map[index + 1] && start_date >= map[index] && end_date > map[index + 1]
            map[index + 1] = end_date
          elsif map[index + 1] && start_date < map[index] && end_date < map[index + 1]
            to_insert_at_start << index
            to_insert_at_end << index + 1
          end   
        end
      end
    end

    to_insert_at_start.each do |index|
      map.insert(index, start_date)
    end

    to_insert_at_end.each do |index|
      map.insert(index, end_date)
    end

    a_a.update_attributes map: "#{map.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')
    a_a.save
  end


  include Services::PubSubBus
  implemented_channels class: [:on_appointment_created]
#=============END PUBSUBBUS
end
