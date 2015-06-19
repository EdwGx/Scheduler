class TeamsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:registration_form, :registration_submit]
  def new
    @team = Team.new
  end

  def create
    @team = Team.create(team_params)
    if @team.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @team = Team.find_by!(:id => params[:id], :user_id => current_user.id)
    @players = @team.players.where(verified: true)
    @unverified_players = @team.players.where(verified: false)
  end

  def destroy
    @team = Team.find_by!(:id => params[:id], :user_id => current_user.id)
    @team.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :destroy }
    end
  end

  def registration_form
    begin
      @team = Team.find_by!(registration_token: params[:token])
      not_found unless @team.allow_registration
      @player = Player.new
      render :registration_form
    rescue
      render :registration_404
    end
  end

  def registration_submit
    @team = Team.find_by!(id: params[:team_id], registration_token: params[:token])
    not_found unless @team.allow_registration
    @player = Player.create(name: params[:player][:name], email: params[:player][:email], team: @team)

    @player.info = [nil] * @team.players_info.count
    @team.players_info.each_with_index do |info, index|
      if info[1] == 0
        @player.info[index] = params[:player][:info][index.to_s]
      else
        year = params[:player][:info]["#{index}(1i)"]
        month = params[:player][:info]["#{index}(2i)"]
        day = params[:player][:info]["#{index}(3i)"]
        unless year.blank? || month.blank? || day.blank?
          @player.info[index] = Date.civil(year.to_i, month.to_i, day.to_i)
        end
      end
    end

    if @player.save
      render :registration_confirmation
    else
      render :registration_form
    end
  end

  def toggle_registration
    @team = Team.find_by!(:id => params[:team_id], :user_id => current_user.id)
    @team.allow_registration = params[:reg].present?
    @team.save
    respond_to do |format|
      format.html { redirect_to @team }
      format.js { render :toggle_registration }
    end
  end

  def email
    @team = Team.find_by!(:id => params[:team_id], :user_id => current_user.id)
    if params[:players_type] == 'V'
      @players = @team.players.where(verified: true).pluck(:email).compact
    elsif params[:players_type] == 'U'
      @players = @team.players.where(verified: false).pluck(:email).compact
    else
      return
    end

    TeamMailer.send_mails_to(@players, params[:subject], params[:content]).deliver_later
  ensure
    redirect_to @team
  end

  def update_registration_form
  end

  private
  def team_params
    params.require(:team).permit(:name).merge!(:user_id => current_user.id)
  end


end
