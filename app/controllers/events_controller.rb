class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :accept_request, :reject_request]
  # set_event was deactivated for :join
  before_filter :authenticate_user!, only: [:new, :edit, :create, :update, :destroy, :join]
  before_action :event_owner!, only:[:edit,:update,:destroy, :accept, :reject]
  # respond_to :html, :json

  # GET /events
  # GET /events.json
  def index
    if params[:tag]
      @events = Event.tagged_with(params[:tag])
    else
      @events = Event.all
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event_owners = []
    @event_owners << @event.organizer
    # @attendees = Event.show_accepted_attendees(@event.id)
    @pending_requests = Attendance.pending.where(event_id: @event.id)
    @attendees = Attendance.accepted.where(event_id: @event.id)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  def my_events
    @events = Event.show_accepted_attendees(current_user.id)
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.organized_events.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

# def tag_cloud
#   @tags = Event.tag_counts_on(:tags)
# end

def accept_request
  @attendance = Attendance.find_by(id: params[:attendance_id]) rescue nil
  @attendance.accept!
  flash[:notice] = 'Applicant Accepted' if @attendance.save
  # respond_with(@event)
  respond_with(@attendance)
end

 def reject_request
  @attendance = Attendance.where(params[:attendance_id]) rescue nil
  @attendance.reject!
  flash[:notice] = 'Applicant Rejected' if @attendance.save
  # respond_with(@event)
  respond_with(@attendance)
end

def join
 # ??? Why does the respond_with code not work
 #  @attendance = Attendance.join_event(current_user.id, params[:event_id], 'request_sent')
 # 'Request Sent' if @attendance.save
 #  # respond_with @event
 #   respond_with(@attendance)

  respond_to do |format|
    # ??? Need to DRY up this code using respond_with
    @attendance = Attendance.join_event(current_user.id, params[:event_id], 'request_sent')
    
    #Need to DRY up this line by removing the search for @event, since the default action is using friendly_id and friendly_id is not passed from the link_to in the show#view
    @event = Event.find(params[:event_id])

    if @attendance.save
      format.html { redirect_to @event, notice: 'Attendance was updated.' }
      format.json { render :show, status: :ok, location: @event }
    else
      format.html { render :edit }
      format.json { render json: @event.errors, status: :unprocessable_entity }
    end
  end
end

def my_events
  @events = current_user.organized_events
end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:title, :start_date, :end_date, :location, :agenda, :address, :organizer_id, :all_tags, :user_id, :brand, :remote_brand_url)
  end

  def event_owner!
    authenticate_user!
    if @event.organizer_id.to_i != current_user.id
      redirect_to events_path
      flash[:notice] = 'You do not have enough permissions to do this'
      puts 'You do not have enough permissions to do this'
    end
  end

end
