class Image < ActiveRecord::Base
  belongs_to :user

  has_attached_file :file

  validates_attachment :file, presence: true,
  											content_type: {content_type: /\Aimage/},
  											file_name: {matches: [/png\Z/, /jpe?g\Z/]},
  											size: { less_than: 1.megabytes }

 	#defining getter for possibility to pass url when rendering images as_json (e.g. as_json methods: [:url])
  def url	
   	self.file.url
  end 
end
