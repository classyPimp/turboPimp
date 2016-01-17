class User < ActiveRecord::Base

  DEFAULT_PASSWORD = '123456'

  @arbitrary = {}

  class << self

    attr_accessor :arbitrary

  end


  rolify

  accepts_nested_attributes_for :roles,
                                allow_destroy: true, reject_if: :all_blank


# => ################AUTHENTICATION
  ACTIVATABLE = false
  
  attr_accessor :activation_token #ACTIVATION

  attr_accessor :reset_token
  
  attr_accessor :remember_token

############### => VALIDATIONS

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i


  with_options unless: ->{ User.arbitrary[:register_as_guest] } do |user|
    user.validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  end
  
  validates :password, presence: true, 
                      length: { minimum: 6 },
                      confirmation: true

  ########### VALIDATION METHODS



  ############
                        
######################################################

############################ CALLBACKS ##################3
  
  before_validation :handle_unregistered_user


    ####################### CALLBACK METHODS

  def handle_unregistered_user
    if User.arbitrary[:register_as_guest] == true
      self.password = self.class::DEFAULT_PASSWORD
      self.password_confirmation = self.class::DEFAULT_PASSWORD
      self.registered = false
      return true
    else
      return true
    end
  end

    ##################################

########################################################

  before_save :downcase_email, unless: ->{ User.arbitrary[:register_as_guest] }

  before_create :create_activation_digest #ACTIVATION

  has_secure_password

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                 BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def downcase_email
    self.email = email.downcase 
  end

  def create_activation_digest
    self.activation_token = self.class.new_token
    self.activation_digest =  self.class.digest(activation_token)
  end

  def activate
    update_attribute :activated, true
    update_attribute :activated_at, Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest # RESET PASSWORD
    self.reset_token = self.class.new_token
    self.update_attribute(:reset_digest, self.class.digest(reset_token))
    self.update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end
  #//////         END AUTHENTICATION

  EXPOSABLE_ATTRIBUTES = [:id, :email, :created_at, :updated_at]

  has_one :profile, dependent: :destroy
  has_one :profile_id_name, ->{ select(:id, :user_id, :name) }, class_name: :Profile
  has_one :si_profile1id_name, ->{select(:id, :name, :user_id)}, class_name: "Profile"

  has_one :avatar, dependent: :destroy

  has_many :blogs
  has_many :pages

  has_many :appointment_availabilities
  #need to set self.class.artbitrary to {from: Date.iso8601, to: Date.iso8601}
  has_many :si_appointment_availabilities1apsindex, ->{select(:id, :user_id, :for_date, :map).where("for_date >= ? AND for_date <= ?", User.arbitrary[:from], User.arbitrary[:to])}, class_name: "AppointmentAvailability"

  accepts_nested_attributes_for :avatar, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :profile, allow_destroy: true

#ROLIFY
  rolify :before_add => :before_role_add

  def before_role_add(role)
    if role.resource_type == "Page"
      raise "assigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_page_roles.include? role.name
    elsif role.resource_type == "Blog"
      raise "ssigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_blog_roles.include? role.name
    else 
      raise "assigned role to #{self} not in the allowed role names" unless Services::RoleManager.allowed_global_roles.include? role.name
    end
  end
###############


end
