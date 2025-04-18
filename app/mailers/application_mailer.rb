class ApplicationMailer < ActionMailer::Base
  default from: ENV["GMAIL_USERNAME"] || "Pimpakan2545@gmail.com"
  layout "mailer"
end
