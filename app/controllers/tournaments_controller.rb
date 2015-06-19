class TournamentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :calendar]
  require 'RRSchedule'

  def index
    @tournaments = current_user.tournaments.pluck(:id, :name)
  end

  def show
    @tournament = Tournament.includes(:matches).where(:id => params[:id]).take!
    matches = @tournament.matches.all.includes(:field).order(start_at: :asc)

    if user_signed_in?
      @admin = @tournament.user_id == current_user.id
    else
      @admin = false
    end

    @list = []
    date = nil

    @teams = {}
    teams_set = Set.new()

    current_fields = Set.new()

    matches.each do |match|
      if match.start_at.to_date != date
        date = match.start_at.to_date
        @list << []
      end
      @list[-1]  << match
      current_fields << match.field_id

      home_team = match.home_team
      away_team = match.away_team

      unless teams_set.include? home_team.id
        teams_set << home_team.id
        @teams[CGI::escape(home_team.name)] = [home_team.name,home_team.id.to_s]
      end

      unless teams_set.include? away_team.id
        teams_set << away_team.id
        @teams[CGI::escape(away_team.name)] = [away_team.name,away_team.id.to_s]
      end
    end

    @list.map! do |day_list|
      fields_dict = {}
      day_list.each do |match|
        name = match.field.name + '-$-' + match.field.id.to_s
        fields_dict[name] = [] unless fields_dict.has_key?(name)
        fields_dict[name] << match
      end
      new_list = []
      fields_dict.keys.sort.each do |key|
        new_list << fields_dict[key]
      end
      new_list
    end


    @unused_teams = current_user.teams.where.not(id: teams_set.to_a).all

    @fields = current_user.fields.pluck(:id, :name)
    @fields.map! do |field|
      field << current_fields.include?(field[0])
      field
    end
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.create(tournament_params)
    if @tournament.save
      redirect_to root_path
    else
      render :new
    end
  end

  def auto_generate
    if params[:name].blank?
      render plain: 'Tournament must have a name'
      return
    end

    if params[:teams].nil? or params[:fields].nil?
      render plain: 'You must choose at least two teams and one field'
      return
    end

    tour_start = Time.zone.parse(params[:start])
    tour_end = Time.zone.parse(params[:end])

    teams = params[:teams].keys.map{|e| e.to_i }
    fields = params[:fields].keys.map{|e| e.to_i }

    if teams.length < 2 or fields.length < 1
      render plain: 'You must choose at least two teams and one field'
      return
    end

    name = params[:name]

    matches = []
    t_len = teams.length
    for i in 0..(t_len - 2)
      for j in (i + 1)..(t_len - 1)
        matches << [i,j]
      end
    end
    #matches.shuffle!
    time_slots = []
    fields.each do |field_id|
      field = Field.find_by(:id => field_id, :user_id => current_user.id)
      time_slots.concat field.available_timeslots(start: tour_start, end: tour_end)
    end
    time_slots.sort!
    latest_match = Array.new(teams.length)
    latest_match.map!{ [nil,0] }

    list = []
    while matches.length > 0 and time_slots.length > 0
      slot = time_slots.shift
      max_num = 0
      max_match = 0
      matches.each_with_index do |m,i|
        a_info = latest_match[m[0]]
        a = eval_team_for_slot(slot[0], a_info[0], a_info[1])

        b_info = latest_match[m[1]]
        b = eval_team_for_slot(slot[0], b_info[0], b_info[1])

        if a > 0 and b > 0
          c = a*b
          if c > max_num
            max_num = c
            max_match = i
          end
        end
      end

      if max_num > 0
        sel_match = matches.delete_at(max_match)
        list << slot.concat(sel_match)
        a = sel_match[0]
        b = sel_match[1]

        l_match = latest_match[a][0]
        if l_match.present?
          if same_week?(l_match, slot[0])
            latest_match[a][1] += 1
          else
            latest_match[a][1] = 0
          end
        end
        latest_match[a][0] = slot[0].dup

        l_match = latest_match[b][0]
        if l_match.present?
          if same_week?(l_match, slot[0])
            latest_match[b][1] += 1
          else
            latest_match[b][1] = 0
          end
        end
        latest_match[b][0] = slot[0].dup

      end

    end
    if matches.length > 0
      render plain: "Not enought time slots"
    else
      tournament =  Tournament.new(name: params[:name], user_id: current_user.id, start_at: tour_start, end_at: tour_end)
      if tournament.save
        list.each do |m|
          match = Match.create(:tournament_id => tournament.id, :field_id => m[2])
          time_slot = Timeslot.find(m[1])
          match.start_at =  time_slot.start_at
          match.timeslot = time_slot
          match.save
          match.home_team = Team.find(teams[m[3]])
          match.away_team = Team.find(teams[m[4]])
        end
        render plain: "OK#{tournament.id}"
      else
        render plain: "Somethings went wrong when creating tournament"
      end
    end
  end

  def destroy
    @tournament = Tournament.find_by!(:id => params[:id], :user_id => current_user.id)
    @tournament.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :destroy }
    end
  end

  def calendar
    @tournament = Tournament.find(params[:tournament_id])

    if params[:start_date].nil?
      first_match = Match.where(:tournament_id => @tournament.id).order(start_at: :ASC).take
      if first_match.present?
        date = @start_date = first_match.start_at
      else
        date = @start_date = Time.zone.now
      end
    else
      date = Time.zone.parse(params[:start_date])
      @start_date = params[:start_date]
    end

    date_range = date.beginning_of_month.beginning_of_week..date.end_of_month.end_of_week
    raw_matches = Match.where(:tournament_id => @tournament.id, :start_at => date_range).order(start_at: :ASC).all
    @matches = {}
    @teams = {}
    teams_set = Set.new()
    raw_matches.each do |match|
      home_team = match.home_team
      away_team = match.away_team

      m_date = match.start_at.to_date
      @matches[m_date] = [] if @matches[m_date].nil?
      @matches[m_date] << [match.id,  match.start_at.to_s(:time), match.field.name, home_team.name, away_team.name, home_team.id, away_team.id]

      unless teams_set.include? home_team.id
        teams_set << home_team.id
        @teams[CGI::escape(home_team.name)] = [home_team.name,home_team.id.to_s]
      end

      unless teams_set.include? away_team.id
        teams_set << away_team.id
        @teams[CGI::escape(away_team.name)] = [away_team.name,away_team.id.to_s]
      end

    end

    if user_signed_in?
      @admin = @tournament.user_id == current_user.id
    else
      @admin = false
    end

  end

  def update_calendar
    error_flag = false
    JSON.parse(params[:changed_events]).each do |id, date|
      begin
        match = Match.find(id)
        d = date.split(/-/)
        match.start_at = match.start_at.change(year: d[0], month: d[1], day: d[2])
        match.save
      rescue
        error_flag = true
      end
    end
    if error_flag
      render plain: "ERROR"
    else
      render plain: "OK"
    end
  end

  def send_schedule
    tournament = Tournament.find_by!(:id => params[:tournament_id], :user_id => current_user.id)
    send_all = params[:content_options] == '0'
    return if params[:teams].nil?
    teams = params.require(:teams).keys.map{|k| k.to_i }

    schedule = {}

    matches = tournament.matches.order(start_at: :asc).all
    matches.each do |m|
      home = m.home_team
      away = m.away_team
      start_date = m.start_at.strftime('%A, %B %d %Y')
      schedule[start_date] = [] if schedule[start_date].nil?
      schedule[start_date] << [m.start_at, home.id, away.id, home.name, away.name, m.field.name]
    end


    if send_all
      sub_schedule = format_schedule(schedule)
      note = 'All matches'
    end

    teams.each do |t|
      next unless Player.exists?(team_id: t)
      unless send_all
        sub_schedule = schedule.dup
        sub_schedule.keep_if do |key, day_sch|
          day_sch.keep_if do |match|
            match[1] == t || match[2] == t
          end
          day_sch.any?
        end
        sub_schedule = format_schedule(sub_schedule)
      end

      team = Team.find(t)
      note = "#{team.name} only" unless send_all
      team.players.each do |player|
        TournamentMailer.schedule_email(player,tournament,sub_schedule,note).deliver_later
      end
    end
  ensure
    redirect_to tournament_path(params[:tournament_id])
  end


  def edit_teams
    @tournament = Tournament.find_by!(:id => params[:tournament_id], :user_id => current_user.id)
    @add_team = params[:type] == 'add'
    @teams = Set.new()
    @old_fields = Set.new() if @add_team
    @tournament.matches.all.each do |match|
      @teams << match.home_team.id
      @teams << match.away_team.id
      @old_fields << match.field_id if @add_team
    end

    @teams = @teams.to_a

    if @add_team
      @fields = current_user.fields.pluck(:id, :name)
      @fields.map! do |team|
        team << @old_fields.include?(team[0])
        team
      end
    end

    if @add_team
      @options = current_user.teams.where.not(id: @teams).all.pluck(:id, :name)
    else
      @options = current_user.teams.where(id: @teams).all.pluck(:id, :name)
    end
  end

  def update_teams
    if params[:type] == 'remove'
      remove_team
      redirect_to tournament_path(params[:tournament_id])
    end
  end

  def add_team
    if params[:team].nil?
      render plain: 'A team must be choosen'
      return
    end

    if params[:fields].nil?
      render plain: 'You must choose at least one field'
      return
    end

    @tournament = Tournament.find_by!(:id => params[:tournament_id], :user_id => current_user.id)

    schedule_machine = RRSchedule.new

    tour_start = Time.zone.parse(params[:start])
    tour_end = Time.zone.parse(params[:end])

    fields = params[:fields].keys.map{|e| e.to_i }

    fields.each do |field_id|
      field = Field.find_by(:id => field_id, :user_id => current_user.id)
      schedule_machine.timeslots.concat field.available_timeslots(start: tour_start, end: tour_end)
    end

    teams = Set.new()
    @tournament.matches.order(start_at: :ASC).all.each do |match|
      home_id, away_id = match.home_team.id, match.away_team.id
      schedule_machine.existed_matches << [match.start_at.to_date, home_id, away_id]

      teams << home_id
      teams << away_id
    end

    team_id = params[:team].to_i
    team = Team.find_by!(:id => params[:team], :user_id => current_user.id)
    schedule_machine.append_matches = teams.to_a.map { |e| [team_id, e] }

    begin
      result = schedule_machine.evaluate
    rescue NotEnoughTimeslotsError
      render plain: "Not enough timeslots"
      return
    end

    result.each do |m|
      match = Match.new(:tournament_id => @tournament.id, :field_id => m[2])
      time_slot = Timeslot.find(m[1])
      match.start_at =  time_slot.start_at
      match.timeslot = time_slot
      match.save
      match.home_team = Team.find(m[3])
      match.away_team = Team.find(m[4])
    end
    render plain: "OK#{@tournament.id}"
  end

  private

  def remove_team
    @tournament = Tournament.find_by!(:id => params[:tournament_id], :user_id => current_user.id)
    team_id = params[:team].to_i
    @tournament.matches.all.each do |match|
      if match.home_team.id == team_id || match.away_team.id == team_id
        match.destroy
      end
    end
  end

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

  def format_schedule(schedule)
    schedule.each do |key, day_sch|
      day_sch.map! do |match|
        "#{match[0].strftime('%l:%M %p')} #{match[3]} vs #{match[4]} @ #{match[5]}"
      end
    end
  end

  def same_week?(a,b)
    a.cweek == b.cweek and a.year == b.year
  end

  def tournament_params
    params.require(:tournament).permit(:name).merge!(:user_id => current_user.id)
  end
end
