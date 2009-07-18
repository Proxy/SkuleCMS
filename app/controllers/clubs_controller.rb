class ClubsController < ApplicationController

  def search
    if !(params[:club]).nil?
      redirect_to :controller => 'clubs', :action => 'search', :id => params[:club][:search]
    elsif !(params[:id]).nil?
      if (@club=Club.find(:first, :conditions => ['name = ?', params[:id]])).nil?
        @clubs = Club.find_tagged_with(params[:id])
      else
        redirect_to(@club)
      end
    else
      @clubs = Club.find(:all)
    end
  end
  
  # GET /clubs
  # GET /clubs.xml
  def index
    @clubs = Club.all
    @tags = Club.find_tagged_with(params[:search])
    
   if false
     respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clubs }
     end
   end
  end

  # GET /clubs/1
  # GET /clubs/1.xml
  def show
    @club = Club.find(params[:id], :include => :tags)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @club }
    end
  end

  # GET /clubs/new
  # GET /clubs/new.xml
  def new
    @club = Club.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @club }
    end
  end

  # GET /clubs/1/edit
  def edit
    @club = Club.find(params[:id])
  end

  # POST /clubs
  # POST /clubs.xml
  def create
    @club = Club.new(params[:club])
    respond_to do |format|
      if @club.save
        directory = "public/club_data/"+@club.name
        if !File.exist?(directory)
          FileUtils.mkdir_p(directory)
        end
        flash[:notice] = 'Club was successfully created.'
        format.html { redirect_to(@club) }
        format.xml  { render :xml => @club, :status => :created, :location => @club }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clubs/1
  # PUT /clubs/1.xml
  def update
    @club = Club.find(params[:id])

    respond_to do |format|
      if @club.update_attributes(params[:club])
        flash[:notice] = 'Club was successfully updated.'
        format.html { redirect_to(@club) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1
  # DELETE /clubs/1.xml
  def destroy
    @club = Club.find(params[:id])
    @club.destroy

    respond_to do |format|
      format.html { redirect_to(clubs_url) }
      format.xml  { head :ok }
    end
  end
end
