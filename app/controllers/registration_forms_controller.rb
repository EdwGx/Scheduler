class RegistrationFormsController < ApplicationController
  before_action :set_team, only: [:update, :destroy]
  INPUT_TYPE = [:text, :date]
  def edit
    index = params[:info_id].nil? ? nil : (params[:info_id].to_i - 1)
    @add_field = index.nil?

    unless @add_field
      set_team
      if index >= 0 && index < @team.players_info.count
        @name = @team.players_info[index][0]
        @type = @team.players_info[index][1]
      else
        not_found
      end
    end

  end

  def update
    return if params[:type].empty? || params[:name].empty?
    type_index = INPUT_TYPE.index(params[:type].downcase.to_sym)
    return if type_index.nil?

    name = params[:name]
    index = params[:info_id].nil? ? nil : (params[:info_id].to_i - 1)
    if index.nil?
      exist_index = @team.players_info.index {|e| e[0] == name}
      if exist_index.nil?
        add = true
      else
        index = exist_index
        add = false
      end
    else
      add = false
    end

    if add
      @team.players.all.each do |player|
        player.info << nil
        player.save
      end
      @team.players_info << [name, type_index]
      @team.save
    else
      unless @team.players_info[index][1] == type_index
        @team.players.all.each do |player|
          player.info[index] = nil
          player.save
        end
      end
      @team.players_info[index] = [name, type_index]
      @team.save
    end
  ensure
    redirect_to @team
  end

  def destroy
    index = params[:info_id].to_i - 1
    @team.players.all.each do |player|
      player.info.delete_at(index)
      player.save
    end
    @team.players_info.delete_at(index)
    @team.save
    redirect_to @team
  end

  private
  def set_team
    @team = Team.find_by!(id: params[:team_id], user: current_user)
  end
end
