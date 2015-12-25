class Appointment < Model

  attributes :start, :end, :patient_id, :doctor_id, :user_id, :scheduled, :appointment_details

  route "Show", get: "appointments/:id"

  route "update", {put: "appointments/:id"}, {defaults: [:id]}

  route "create", post: "appointments"

  route "Index", get: "appointments"

  route "destroy", {delete: "appointments/:id"}, {defaults: [:id]} 

  route "Edit", {get: "appointments/:id/edit"}

  
end