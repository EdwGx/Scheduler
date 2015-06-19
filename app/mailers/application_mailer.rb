class ApplicationMailer < ActionMailer::Base
  default from: "rails.scheduler@gmail.com"
  layout 'mailer'
end
