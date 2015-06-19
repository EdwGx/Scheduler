class MatchesController < ApplicationController
  def new
    @match = Match.new
    render :form
  end

  def create
    @match = Match.create(match_params)
    teams = params_teams
    @match.home_team = Team.find(teams[:home_team])
    @match.away_team = Team.find(teams[:away_team])
    if @match.save
      path = tournament_path(params[:tournament_id]) + '#m-' + @match.id.to_s
      redirect_to path
    else
      render :form
    end
  end

  def edit
    @match = Match.joins(:tournament).where(tournaments: {user_id: current_user.id}, matches: {id: params[:id]}).take!
    render :form
  end

  def update
    @match = Match.joins(:tournament).where(tournaments: {user_id: current_user.id}, matches: {id: params[:id]}).take!

    teams = params_teams
    @match.home_team = Team.find(teams[:home_team])
    @match.away_team = Team.find(teams[:away_team])

    if @match.update_attributes match_params
      path = tournament_path(params[:tournament_id]) + '#m-' + @match.id.to_s
      redirect_to path
    else
      render :form
    end
  end

  def destroy
    unless Tournament.exists?(id: params[:tournament_id], user_id: current_user.id)
      raise ActiveRecord::RecordNotFound
    end
    match = Match.find_by!(id: params[:id], tournament_id: params[:tournament_id])
    match.destroy
    redirect_to tournament_path(params[:tournament_id])
  end

  private
  def match_params
    new_params = params.require(:match).permit(:duration, :field_id).merge!(:tournament_id => params[:tournament_id])
    begin
      start_date = Time.zone.parse(params[:match][:start_at])
      new_params[:start_at] = start_date
    rescue
      new_params[:start_at] = nil
    end
    new_params
  end

  def params_teams
    params.require(:match).permit(:home_team, :away_team)
  end


end
