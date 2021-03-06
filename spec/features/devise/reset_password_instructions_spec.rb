# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Reset password instructions" do
  let(:user) { FactoryGirl.create(:user) }

  context "sends the correct email", with_truncation: true do
    before {
      with_resque { request_password }
    }
    it("sets 'to'") { last_email.to.should eql([user.email]) }
    it("sets 'subject'") {
      text = I18n.t('devise.mailer.reset_password_instructions.subject')
      last_email.subject.should eql(text)
    }
    it("sets 'from'") { last_email.from.should eql([Devise.mailer_sender]) }
    it("sets 'headers'") { last_email.headers.should eql({}) }
    it("sets 'reply_to'") { last_email.reply_to.should eql([Devise.mailer_sender]) }
    it("content") {
      mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.greeting', email: user.email))
      mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.requested'))
      mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.ignore'))
      mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.wont_change'))
    }
  end

  it "uses the receiver's locale", with_truncation: true do
    Site.current.update_attributes(locale: "en")
    user.update_attributes(locale: "pt-br")
    with_resque { request_password }
    last_email.should_not be_nil
    mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.requested', locale: "pt-br"))
  end

  it "uses the site's locale if the receiver has no locale", with_truncation: true do
    Site.current.update_attributes(locale: "pt-br")
    user.update_attributes(locale: nil)
    with_resque { request_password }
    last_email.should_not be_nil
    mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.requested', locale: "pt-br"))
  end

  it "uses the default locale if the site has no locale set", with_truncation: true do
    I18n.default_locale = "pt-br"
    Site.current.update_attributes(locale: nil)
    user.update_attributes(locale: nil)
    with_resque { request_password }
    last_email.should_not be_nil
    mail_content(last_email).should match(I18n.t('devise.mailer.reset_password_instructions.requested', locale: "pt-br"))
  end

  def request_password
    visit new_user_password_path
    fill_in 'user[email]', with: user.email
    click_button t('user.request_password')
  end
end
