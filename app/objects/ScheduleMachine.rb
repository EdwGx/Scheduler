class ScheduleMachine
  attr_accessor :timeslots, :append_matches, :existed_matches
  def initialize
    @timeslots = []
    @append_matches = []
    @existed_matches = []
  end

end

class NotEnoughTimeslotsError < StandardError
end
