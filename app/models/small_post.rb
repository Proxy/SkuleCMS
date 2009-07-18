class SmallPost < ActiveRecord::Base
  
  minLimit = 2.freeze
  maxLimit = 20.freeze

  validates_length_of :content, 
                      :within => minLimit..maxLimit,
                      :too_long => "Error: Sorry, you can only have a maximum of %d characters. Would you like to try a twat instead?",
                      :too_short => "Error: Sorry, you need a minimum of %d characters to make a post."
  
end
