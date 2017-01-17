require "./stpete_crystal/*"
require "kemal"
require "kemal-session"
require "kilt/slang"

module StpeteCrystal

  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes # 2 minutes
  end

  get "/hello" do |context|
    update_session(context.session)
  end

  get "/hello/:name" do |context|
    update_session(user_session: context.session, 
                   visitor_name: context.params.url["name"])
  end

  # updates the current visitor's session, including the name.
  # This exploits one of crystal's features that's not
  # available in ruby: method overloads.
  def self.update_session( user_session : Session, visitor_name : String)
    user_session.string("name", visitor_name)
    update_session(user_session)
  end

  def self.update_session( user_session : Session)
    # update the visit count
    visit_count = (user_session.int?("visit_count") || 0 ) + 1
    user_session.int("visit_count", visit_count)

    # create the start time if it's not already there
    unless user_session.string?("session_started")
      user_session.string("session_started", Time.now.to_s) 
    end
    display_hello( user_session)
  end

  # tie all the information we have on the visitor together
  # into a string.
  def self.display_hello( user_session : Session)
    if user_session.string?("name")
      name = user_session.string("name").capitalize
    else
      name = "web"
    end
    session_started = user_session.string("session_started")
    session_visits = user_session.int("visit_count")
    render "./src/page.slang"


    # if user_session.string?("name")
    #   user_name = user_session.string("name").capitalize
    # else
    #   user_name = "web"
    # end
    # "Hello #{user_name}! Your visit started 
    #  #{user_session.string("session_started")} 
    #  and you've loaded #{user_session.int("visit_count")} pages."
  end

  Kemal.run

end
