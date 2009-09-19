class Group < ActiveRecord::Base
  belongs_to      :club
  has_many        :memberships, :dependent => :destroy
  has_many        :users,   :through => :memberships
  #better nested tree

  attr_writer :new_page
  validates_length_of       :name, :in => 3..50
  validates_length_of       :misc, :maximum => 400
  validates_uniqueness_of   :name, :case_sensitive => false, :scope => [:club_id]
  validates_numericality_of :order

  attr_protected :id, :club_id, :created_at, :updated_at, :membership_ids, :user_ids

  acts_as_nested_set  :parent_column => "bns_parent_id",
                      :left_column => "lft",
                      :right_column => "rgt",
                      :text_coloumn => "name"
  
  before_validation_on_create :check_parent_id
  after_save :move_to_parent
  
  def check_parent_id
    if self.parent_id.blank? && !self.is_member_list?
      self.parent_id = self.club.member_list.id
      self.bns_parent_id = self.club.member_list.id
    end
  end
  
  def new_page
    @new_page
  end
  
  def is_member_list?
    return self.name.eql?("Member List")
  end
  
  def move_to_parent
    if !self.name.eql?("Member List")
      if !self.parent_id.blank?
        self.move_to_child_of(self.club.groups.find(self.parent_id))
      else
        self.parent_id = self.club.member_list.id
        self.move_to_child_of(self.club.member_list)
      end
      self.parent.order_by_weight
    end
  end
  
  def order_by_weight
    @sorted = self.children.sort_by{ |i| i[:order] }
    1.upto(@sorted.length-1) do |n|
      @sorted[n].move_to_right_of(@sorted[n-1])
    end
  end
  
  #This is for fixture loading. Don't use unless necessary.
  def self.rebuild_tree
    @groups = Group.find(:all, :conditions => ['bns_parent_id IS ?', nil])
    @groups.each do |group|
      group.recreate_node
    end
        
    @clubs = Club.all
    @clubs.each do |club|
      club.member_list
    end
    #rebuild!
    Group.find(:all, :conditions => ['bns_parent_id IS NOT ?', nil]).each do |group|
      group.order_by_weight
    end
  end
  
  def indented_name
    @spacing = ""
    (self.level-2).times { @spacing += "&nbsp;&nbsp;"}
    if (self.level >=2 )
      @spacing += "&nbsp;&nbsp;"
    end
    return @spacing+self.name
  end
  
  def recreate_node(parent_node = nil)
    @childs = Group.find(:all, :conditions => ["parent_id = ?", self.id])
    @members = self.users
    @node = self.club.groups.new
    @node.parent_id = parent_node
    @node.bns_parent_id = parent_node
    @node.misc = self.misc
    @node.name = self.name
    @node.order = self.order
    @node.save_with_validation(false)
    @members.each do |member|
      @membership = Membership.new
      @membership.user = member
      @membership.group = @node
      @membership.save
    end
    @childs.each do |child|
      child.recreate_node(@node.id)
    end
    self.destroy
  end
end
