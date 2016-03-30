class OfferedServiceAvatar < ActiveRecord::Base

  belongs_to :offered_service
  
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment :avatar, presence: true,
                        content_type: {content_type: /\Aimage/},
                        file_name: {matches: [/png\Z/, /jpe?g\Z/]},
                        size: { less_than: 1.megabytes }

  #used in JSON serializing e/g/ @avatr.as_json(methods: [:url])
  def url 
    self.avatar.url(:thumb)
  end 

end
