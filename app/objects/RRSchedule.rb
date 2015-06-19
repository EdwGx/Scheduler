require 'ScheduleMachine'
class RRSchedule < ScheduleMachine
  def evaluate
    week_sch = Hash.new { |h, k| h[k] = Hash.new(0) }
    day_sch = Hash.new { |h, k| h[k] = Hash.new(0) }
    last_match = {}

    #existed_matches [[date, home_id, away_id], ...]
    #append_matches [[home_id, away_id], ...]
    #timeslots [[date, timeslot_id, field_id], ...]
    raise NotEnoughTimeslotsError if @timeslots.empty?

    @existed_matches.each do |match|
      match_date, home_id, away_id = match
      week_identifier = [match_date.year, match_date.cweek]

      week_sch[week_identifier][home_id] += 1
      #day_sch[match_date][home_id] += 1

      week_sch[week_identifier][away_id] += 1
      #day_sch[match_date][away_id] += 1
    end

    matches_list = []
    while @append_matches.length > 0 && @timeslots.length > 0
      timeslot = @timeslots.shift
      timeslot_date = timeslot[0]

      week_identifier = [timeslot_date.year, timeslot_date.cweek]

      max_option = [0, 0]
      @append_matches.each_with_index do |match, index|
        home_id, away_id = match

        home_last_match = last_match[home_id]
        a = eval_team_for_slot(timeslot_date, home_last_match, week_sch[week_identifier][home_id])

        away_last_match = last_match[away_id]
        b = eval_team_for_slot(timeslot_date, away_last_match, week_sch[week_identifier][away_id])

        if a > 0 and b > 0
          c = a*b
          if c > max_option[0]
            max_option = c, index
          end
        end
      end

      if max_option[0] > 0
        selected_match = @append_matches.delete_at(max_option[1])
        matches_list << timeslot.concat(selected_match)

        home_id, away_id = selected_match

        week_sch[week_identifier][home_id] += 1
        week_sch[week_identifier][away_id] += 1

        last_match[home_id] = last_match[away_id] = timeslot_date.dup
      end
    end

    if @append_matches.length > 0
      raise NotEnoughTimeslotsError
    else
      return matches_list
    end
  end

  private
  def eval_team_for_slot(date, last_match_date, num_in_week)
    if last_match_date.nil?
      return 9
    elsif date == last_match_date
      return 0
    elsif num_in_week >= 2 and same_week?(last_match_date,date)
      return 0
    else
      return [(date - last_match_date).to_i, 9].min
    end
  end

  def same_week?(a,b)
    a.cweek == b.cweek and a.year == b.year
  end
end
