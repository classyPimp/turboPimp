class Avatar < ActiveRecord::Base


  belongs_to :user
  
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment :file, presence: true,
                        content_type: {content_type: /\Aimage/},
                        file_name: {matches: [/png\Z/, /jpe?g\Z/]},
                        size: { less_than: 1.megabytes }

end
