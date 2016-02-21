class Event < ActiveRecord::Base
	 belongs_to :organizers, class_name: "User"
	 extend FriendlyId
     	friendly_id :title, use: :slugged
end
