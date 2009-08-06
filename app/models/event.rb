class Event < ActiveRecord::Base
  has_event_calendar

  belongs_to      :club
  belongs_to      :user
  
  validates_presence_of     :start, :finish, :club_id, :location, :name
  validates_length_of       :name, :maximum => 20
  validates_length_of       :link, :maximum => 255
  validates_length_of       :description, :maximum => 255
  validates_length_of       :location, :maximum => 255
  validates_numericality_of :club_id
  
  def start_at
    return start
  end
  
  def end_at
    return finish
  end
  
  def validate
    errors.add_to_base "Ending time cannot be before start time" if !(check_time?(start, finish))
  end

  def check_time?(start, finish)
    return finish >= start
  end
end
