class Event < ActiveRecord::Base
	belongs_to :organizer, class_name: "User"
  # belongs_to :user
	
	extend FriendlyId
	friendly_id :title, use: :slugged

 	has_many :taggings
 	has_many :tags, through: :taggings

  has_many :attendances
  has_many :users, :through => :attendances

  def all_tags=(names)
	  self.tags = names.split(",").map do |t|
	    Tag.where(name: t.strip).first_or_create!
	  end
	end

	def all_tags
    result = tags.map(&:name).join(", ") 
  end

  def self.tagged_with(name)
    Tag.find_by_name!(name).events
  end

  def self.tag_counts
     Tag.select("tags.name, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id")
  end

  def self.event_owner(organizer_id)
    User.find_by id: organizer_id
  end

  def self.pending_requests(event_id)
    Attendance.where(event_id: event_id, state:'request_sent')
  end

  def self.show_accepted_attendees(event_id)
    Attendance.accepted.where(event_id: event_id)
  end

end 