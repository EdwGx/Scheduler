class Timeslot < ActiveRecord::Base
  belongs_to :field
  belongs_to :match
  validates_presence_of :field, :start_at
end
