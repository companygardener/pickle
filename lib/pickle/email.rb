module Pickle
  module Email
    # return the deliveries array, optionally selected by the passed fields
    def emails(fields = nil)
      returning @emails = ActionMailer::Base.deliveries do |emails|
        emails.reject!{|m| !email_matches?(m, fields)}
      end
    end

    def email(ref, fields = nil)
      (match = ref.match(/^#{capture_index_in_email}$/)) or raise ArgumentError, "argument should match #{match_email}"
      @emails or raise RuntimeError, "Call #emails before calling #email"
      index = parse_index(match[1])
      email_matches?(@emails[index], fields) && @emails[index]
    end
    
    def email_matches?(email, fields)
      return true if fields.blank?
      parse_fields(fields).each do |key, val|
        return false unless (Array(email.send(key)) & Array(val)).any?
      end
      true
    end
    
  protected
    # Saves the emails out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. (depends on webrat)
    def save_and_open_emails
      emails_to_open = @emails || emails
      filename = "#{RAILS_ROOT}/tmp/webrat-email-#{Time.now.to_i}.html"
      File.open(filename, "w") do |f|
        emails_to_open.each_with_index do |e, i|
          f.write "<h1>Email #{i+1}</h1><pre>#{e}</pre><hr />"
        end
      end
      open_in_browser(filename)
    end
  end
end