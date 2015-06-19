class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  include ActionView::Helpers::TextHelper
  def index
    if user_signed_in?
      @tournaments = current_user.tournaments.pluck(:id, :name)
      @tournaments.map! do |tour|
        tour << pluralize(Match.where(tournament_id: tour[0]).count, 'match')
        tour
      end
      @fields = current_user.fields.pluck(:id, :name, :location)
      @fields.each do |f|
        f[2] = nil if f[2].nil? || f[2].empty?
      end
      @teams = current_user.teams.pluck(:id, :name)
      @teams.map! do |team|
        team << nil
        team
      end
      render :show
    end
  end

  def xlsx_import
    uploaded_io = params[:xlsx_file]
    ext = file_extension(uploaded_io.original_filename)
    if ext != '.xlsx'
      alert = 'Invalid file format, xlsx file only'
      return
    end
    xlsx = Roo::Spreadsheet.open(uploaded_io.path)

    sheets = xlsx.sheets
    xlsx.sheet(sheets.index('Teams')).column(1)[1..-1].each do |team_name|
      Team.create(:name => team_name, :user_id => current_user.id).save
    end

    i = 2
    fields_sheet = xlsx.sheet(sheets.index('Fields'))
    fields_sheet.column(1)[1..-1].each do |field_name|
      field_info = fields_sheet.row(i)
      field = Field.where(:name => field_info[0], :user_id => current_user.id).take
      if field.nil?
        field = Field.create(:name => field_info[0], :user_id => current_user.id)
      end
      field.location = field_info[1]
      if field.save
        field_info.drop(2).each do |time|
          ts = Timeslot.create(:start_at => DateTime.parse(time))
          ts.field = field
          ts.save
        end
      end
      i += 1
    end
    notice = "Teams and fields have imported successfully"
  ensure
    redirect_to root_path, alert: alert, notice: notice
  end

  def test

  end

  private

  def file_extension(name)
    i = name.length - 1
    until i < 0
      if name[i] == '.'
        return name[i..-1]
      end
      i -= 1
    end
    nil
  end
end
