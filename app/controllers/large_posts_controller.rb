 require 'pagify/active_record'
 require 'pagify/helper/rails'

class LargePostsController < ApplicationController
    before_filter :load_club
    before_filter :auth_admin, :only => [:admin, :new, :edit, :create, :update, :destroy]

  
     uses_tiny_mce :options => {
                                :theme => 'advanced',
                                :plugins => %w{ advimg media emotions },
                                :theme_advanced_buttons1 => 'bold,italic,underline,strikethrough,|,fontselect,fontsizeselect',
                                :theme_advanced_buttons2 => 'bullist,numlist,|,forecolor,backcolor,|,image,code,|',
                                :theme_advanced_buttons3 => '',
                                :theme_advanced_toolbar_location => 'top',
                                :theme_advanced_toolbar_align => 'left',
                                :theme_advanced_resizing => true,
                                :theme_advanced_statusbar_location => 'bottom',


                              }
  
  
  # GET /large_posts
  # GET /large_posts.xml
  def index
    @large_posts = @club.large_posts.all.pagify(:page =>1, :per_page => 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  {} #{ render :xml => @large_posts }
    end
  end
  
    def admin
       if (params[:id].blank?)
         @posts = @club.large_posts.all + @club.small_posts.all
         respond_to do |format|
          format.html #admin.html.erb
          format.xml { render :xml => @posts }
         end
       else
           @large_post = @club.large_posts.find(params[:id])
           
         respond_to do |format|
          format.html { render :action => "admin_show" }
          format.xml  { render :xml => @large_post }
        end  
      end
  end


  # GET /large_posts/1
  # GET /large_posts/1.xml
  def show
    @large_post = @club.large_posts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @large_post }
    end
  end

  # GET /large_posts/new
  # GET /large_posts/new.xml
  def new
    @large_post = @club.large_posts.new
    
    @large_post.content = params[:content] if params[:content]
    @large_post.club_id = params[:club_id]
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @large_post }
    end
  end



  # GET /large_posts/1/edit
  def edit
    @large_post = @club.large_posts.find(params[:id])
  end

  # POST /large_posts
  # POST /large_posts.xml
  def create
    @large_post = @club.large_posts.new(params[:large_post])


#    @small_post = SmallPost.new
#    @small_post.content = "New Large Post: " + @large_post.title
#    @small_post.club_id = params[:club_id]
#    @small_post.save

    respond_to do |format|
      if @large_post.save
        flash[:notice] = 'LargePost was successfully created.'
        format.html { redirect_to admin_club_large_post_path(@club, @large_post) }
        format.xml  { render :xml => @large_post, :status => :created, :location => @large_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @large_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /large_posts/1
  # PUT /large_posts/1.xml
  def update
    @large_post = @club.large_posts.find(params[:id])

    respond_to do |format|
      if @large_post.update_attributes(params[:large_post])
        flash[:notice] = 'LargePost was successfully updated.'
        format.html { redirect_to admin_club_large_post_path(@club, @large_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @large_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /large_posts/1
  # DELETE /large_posts/1.xml
  def destroy
    @large_post = @club.large_posts.find(params[:id])
    @large_post.destroy

    respond_to do |format|
      format.html { redirect_to(admin_club_large_posts_url) }
      format.xml  { head :ok }
    end
  end
  


  private
  def load_club
    @club = Club.find(params[:club_id])
  end

end
