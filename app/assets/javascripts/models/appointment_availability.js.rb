class AppointmentAvailability < Model
  attributes :id, :map, :user_id, :for_date, :user

  route "Show", get: "appointment_availabilities/:id"

  route "update", {put: "appointment_availabilities/:id"}, {defaults: [:id]}

  route "create", post: "appointment_availabilities"

  route "Index", get: "appointment_availabilities"
  
  route "destroy", {delete: "appointment_availabilities/:id"}, {defaults: [:id]} 

  route "Edit", {get: "appointment_availabilities/:id/edit"}

end