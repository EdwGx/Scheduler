class FieldsController < ApplicationController
  def new
    @field = Field.new
  end

  def show
    @field = Field.find_by!(:id => params[:id], :user_id => current_user.id)
    @timeslots = @field.timeslots.order(start_at: :ASC).all.pluck(:start_at, :end_at, :match_id, :id)

    @timeslots.each do |ts|
      ts[0] = ts[0].nil? ? '' : ts[0].strftime('%B %d, %Y %l:%M %p')
      ts[1] = ts[1].nil? ? '' : ts[1].strftime('%B %d, %Y %l:%M %p')
    end
  end

  def create
    @field = Field.create(field_params)
    if @field.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @field = Field.find_by!(:id => params[:id], :user_id => current_user.id)
  end

  def update
    @field = Field.find_by!(:id => params[:id], :user_id => current_user.id)
    @field.update_attributes params.require(:field).permit(:name, :location)
    redirect_to @field
  end

  def destroy
    @field = Field.find_by!(:id => params[:id], :user_id => current_user.id)
    @field.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render :destroy }
    end
  end

  def update_schedule
    @field = Field.find(params[:field_id])
    @field.update_attribute(:schedule, JSON.parse(params[:schedule]))
    redirect_to root_path
  end

  private
  def field_params
    params.require(:field).permit(:name, :location).merge!(:user_id => current_user.id)
  end
end
