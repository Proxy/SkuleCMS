require 'icalendar'

class EventsController < ApplicationController
  before_filter :load_club
  def load_club
    @club = Club.find(params[:club_id])
  end
  
  
  def export_events
    @calendar = Icalendar::Calendar.new      
    if (!params[:id].blank?)
      @event = Event.find(params[:id])
      event = Icalendar::Event.new
      event.start = @event.start.strftime("%Y%m%dT%H%M%S")
      event.end = @event.finish.strftime("%Y%m%dT%H%M%S")
      event.summary = @event.name+ " - " + @event.club.name
      event.description = @event.description
      event.location = @event.location
      event.url = @event.link
      @calendar.add event
    else
      @events = Event.find(:all, :conditions => ["club_id = :club_id AND finish >= :finish", {:club_id => params[:club_id], :finish => Time.now}])
      @events.each do |event_item|
        event = Icalendar::Event.new
        event.start = event_item.start.strftime("%Y%m%dT%H%M%S")
        event.end = event_item.finish.strftime("%Y%m%dT%H%M%S")
        event.summary = event_item.name+ " - " + event_item.club.name
        event.description = event_item.description
        event.location = event_item.location
        event.url = event_item.link
        @calendar.add event
      end
    end
    @calendar.publish
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render :text => @calendar.to_ical, :layout=> false    
  end
  
  # GET /events
  # GET /events.xml
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/admin
  # GET /events/1/admin
  def admin
    if (params[:id].blank?)
      @events = Event.all
      respond_to do |format|
        format.html # admin.html.erb
        format.xml  { render :xml => @events }
      end
    else
      @event = Event.find(params[:id])
      respond_to do |format|
        format.html { render :action => "admin_show" }
        format.xml  { render :xml => @event }
      end
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @users = User.find(:all)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @users = User.find(:all)
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.club_id = @club.id
    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to admin_club_event_path(@club, @event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        @users = User.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to admin_club_event_path(@club, @event) }
        format.xml  { head :ok }
      else
        @users = User.find(:all)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(admin_club_events_url) }
      format.xml  { head :ok }
    end
  end
end
