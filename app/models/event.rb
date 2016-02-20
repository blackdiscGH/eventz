class Event < ActiveRecord::Base
	 belongs_to :organizers, class_name: "User"
end
