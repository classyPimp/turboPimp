class Profile < ActiveRecord::Base

  include Services::CustomErrorable
  # def self.includes_with_select(*m)
  #   association_arr = []
  #   m.each do |part|
  #     parts = part.split(':')
  #     association = parts[0].to_sym
  #     select_columns = parts[1].split('-')
  #     association_macro = (self.reflect_on_association(association).macro)
  #     association_arr << association.to_sym
  #     class_name = self.reflect_on_association(association).class_name 
  #     self.send(association_macro, association, -> {select *select_columns}, class_name: "#{class_name.to_sym}")
  #   end
  #   self.includes(*association_arr)
  # end
 
  # def self.includes_with_select_a(macro, assoc_name, class_name, *args)
  #   self.send(macro, assoc_name, -> {select *args}, class_name: class_name)
  #   self.includes(assoc_name)
  # end

  belongs_to :user

  validates :name, presence: true

  scope :patients_for_feed, ->{joins(user: [:roles]).where("roles.name = ? AND users.registered = ?", "patient", true).select(:user_id, :name)}

end
