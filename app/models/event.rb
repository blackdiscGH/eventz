class Event < ActiveRecord::Base
	 belongs_to :organizers, class_name: "User"
	 extend FriendlyId
     	friendly_id :title, use: :slugged

     	has_many :taggings
     	has_many :tags, through: :taggings

    def all_tags=(names)
	   self.tags = names.split(",").map do |t|
	     Tag.where(name: t.strip).first_or_create!
	   end
	end

	def all_tags
        tags.map(&:name).join(", ")
    end
end
