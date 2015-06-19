class TimeslotsController < ApplicationController
  def new
    @timeslot = Timeslot.new
    render :form
  end

  def create

    @timeslot = Timeslot.create params.require(:timeslot).permit(:start_at,:end_at)
    @timeslot.field_id = params[:field_id]

    if @timeslot.save
      redirect_to field_path(params[:field_id])
    else
      render :form
    end

  end

  def edit
    @timeslot = Timeslot.joins(:field).where(fields: {user_id: current_user.id}, timeslots: {id: params[:id]}).take!
    render :form
  end

  def update
    @timeslot = Timeslot.joins(:field).where(fields: {user_id: current_user.id}, timeslots: {id: params[:id]}).take!

    if @timeslot.update(params.require(:timeslot).permit(:start_at,:end_at))
      redirect_to field_path(params[:field_id])
    else
      render :form
    end
  end

  def destroy
    timeslot = Timeslot.joins(:field).where(fields: {user_id: current_user.id}, timeslots: {id: params[:id]}).take!
    timeslot.destroy
    redirect_to field_path(params[:field_id])
  end
end
