class User < ActiveRecord::Base
  rolify

  accepts_nested_attributes_for :roles,
                                allow_destroy: true, reject_if: :all_blank


# => ################AUTHENTICATION
  ACTIVATABLE = false
  
  attr_accessor :activation_token #ACTIVATION

  attr_accessor :reset_token
  
  attr_accessor :remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  validates :password, presence: true, length: { minimum: 6 }, presence: true,
                        confirmation: true,
                        if: ->{ new_record? || !password.nil? }

  before_save :downcase_email

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

  has_one :avatar, dependent: :destroy

  accepts_nested_attributes_for :avatar, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :profile, allow_destroy: true

  rolify :before_add => :before_add_method

  def before_add_method(role)
    unless Services::RoleManager.allowed_roles.include? role.name
      raise "assigned role to #{self} not in the allowed role names"
    end
  end

end
