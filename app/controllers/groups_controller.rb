class GroupsController < ApplicationController
  before_filter :load_club
  def load_club
    @club = Club.find(params[:club_id])
  end
  
  # GET /groups
  # GET /groups.xml
  def index
    @groups = @club.groups
    @roots = Group.find(:all, :conditions => {:club_id => @club, :parent_id => nil})
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    @page = @club.pages.find(:first, :conditions=> ["title=?",@group.name])


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    @grouplist = @club.groups
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @grouplist = @club.groups
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])
    @group.club = @club
    respond_to do |format|
      if @group.save
        if !params[:group][:parent_id].blank?
          @group.move_to_child_of(Group.find(params[:group][:parent_id]))
        end
        if !params[:page].nil? && !params[:page]['create_page'].nil?
          @page = Page.new
          @page.title = @group.name
          @page.club = @club
          @page.save
        end
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to club_group_path(@club, @group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        if !params[:group][:parent_id].blank?
          @group.move_to_child_of(Group.find(params[:group][:parent_id]))
        end
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to club_group_path(@club, @group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(club_groups_url) }
      format.xml  { head :ok }
    end
  end
end
