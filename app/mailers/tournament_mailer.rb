class TournamentMailer < ApplicationMailer
  def schedule_email(player, tournament, schedule, note)
    @player = player
    @tournament = tournament
    @schedule = schedule
    @note = note
    mail(to: @player.email, subject: "Schedule of #{@tournament.name}")
  end

  def test(email)
    mail(to: email, subject: "Test") do |f|
      f.text do
        render :text => 'Hello World!'
      end
    end
  end
end
