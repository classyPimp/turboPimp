class Blog < ActiveRecord::Base


# PLUGINS AND EXTENSIONS THIRD PARTY
  extend FriendlyId
  friendly_id :title, use: :slugged

  include PgSearch
  pg_search_scope :search_by_title_body, :against => [:title, :body]

  #pg serach scope methods

  def published?
    self.published = true    
  end

#VALIDATIONS
  validates :body, presence: true, length: {minimum: 10}

  validates :published, datetime: false

  validates :title, presence: true, length: {minimum: 1}


#ASSOCIATIONS  
  belongs_to :user
  has_one :author, ->{select(:user_id, :name)}, through: :user, source: :profile
  scope :published, ->{where(published: true)}

#CALLBACKS
  before_validation :set_published_value, on: [:create, :update]
  before_validation :strip_white_space, on: [:create, :update]



#CALLBACK METHODS

  def set_published_value #STOPPED HERE!
    if self.published_changed?
      if self.published
        self.published_at = Time.now
      else
        self.published_at = nil
      end
    end
  end

  def strip_white_space
    self.body = self.body.try(:strip)
    self.title = self.title.try(:strip)
  end

end
