class TeamMailer < ApplicationMailer
  def send_mails_to(recipients, subject, content)
    mail(to: recipients, subject: subject, body: content)
  end
end
