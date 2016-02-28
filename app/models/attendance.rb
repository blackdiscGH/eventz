class Attendance < ActiveRecord::Base
	belongs_to :user
	belongs_to :event
	scope :accepted, -> {where(state: 'accepted')}
	scope :pending, -> {where(state: 'request_sent')}

	def self.join_event(user_id,event_id,state)
		self.create(user_id: user_id, event_id: event_id, state: state)
	end

	include Workflow
     workflow_column :state

	workflow do
	   state :request_sent do
	   		event :accept, :transitions_to => :accepted
	   		event :reject, :transitions_to => :rejected
		end
	   	state :accepted
	   	state :rejected
	end


end
