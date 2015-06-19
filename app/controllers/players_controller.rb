class PlayersController < ApplicationController
  before_action :set_team, only: [:new, :create, :edit, :update]
  def new
    @player = Player.new
    @submit = 'Create'
    render :form
  end

  def create
    @player = Player.new(player_params)
    @player.verified = true
    update_player_info(@player, @team)
    @submit = 'Create'
    if @player.save
      redirect_to team_path(params[:team_id])
    else
      render :form
    end
  end

  def destroy
    @player = Player.joins(:team).where(teams: {user_id: current_user.id}, players: {id: params[:id]}).take
    raise ActiveRecord::RecordNotFound if @player.nil?
    @player.destroy
    redirect_to team_path(params[:team_id])
  end

  def edit
    @player = Player.joins(:team).where(teams: {user_id: current_user.id}, players: {id: params[:id]}).take
    raise ActiveRecord::RecordNotFound if @player.nil?
    @submit = 'Edit'
    render :form
  end

  def update
    @player = Player.joins(:team).where(teams: {user_id: current_user.id}, players: {id: params[:id]}).take!

    update_player_info(@player, @team)

    if @player.update_attributes params.require(:player).permit(:name, :email)
      redirect_to team_path(params[:team_id])
    else
      @submit = 'Edit'
      render :form
    end
  end

  def verify
    @player = Player.joins(:team).where(teams: {user_id: current_user.id, id: params[:team_id]}, players: {id: params[:player_id]}).take!
    @player.update_attributes! verified: true
    redirect_to team_path(@player.team_id)
  end

  private
  def player_params
    params.require(:player).permit(:name, :email).merge!(:team_id => params[:team_id])
  end

  def set_team
    @team = Team.find_by!(id: params[:team_id], user: current_user)
  end

  def update_player_info(player, team)
    player.info = [nil] * team.players_info.count
    team.players_info.each_with_index do |info, index|
      if info[1] == 0
        player.info[index] = params[:player][:info][index.to_s]
      else
        year = params[:player][:info]["#{index}(1i)"]
        month = params[:player][:info]["#{index}(2i)"]
        day = params[:player][:info]["#{index}(3i)"]
        unless year.blank? || month.blank? || day.blank?
          player.info[index] = Date.civil(year.to_i, month.to_i, day.to_i)
        end
      end
    end
  end
end
