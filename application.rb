require 'rubygems'
require 'bundler'
require 'sinatra'
require 'json'
require 'active_record'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'google/api_client'
require 'newrelic_rpm'
require 'pp'
require 'aws/s3'
Bundler.require(:default)

require './models/user'
require './models/notification'
require './helpers/yoursharehelper'
require './helpers/mirror'

class Application < Sinatra::Base
  helpers Sinatra::MirrorHelper
  helpers Sinatra::YourShareHelper
  enable :sessions

  SCOPES = [
    'https://www.googleapis.com/auth/glass.timeline',
    'https://www.googleapis.com/auth/userinfo.profile' ]
  APP_NAME        = "YOUR_APP_NAME"
  APP_IMAGE_URL   = "YOUR_APP_IMAGE_URL"
  SERVICE_NAME    = "THE_SERVICE_YOU_SHARE_TO"

  set :bucket,      'YOUR_S3_BUCKET'
  set :s3_key,      'YOUR_S3_KEY'
  set :s3_secret,   'YOUR_S3_SECRET'


def api_client; settings.api_client; end
def mirror_api; settings.mirror_api; end
def oauth2_api; settings.oauth2_api; end

def store_credentials(user_id, credentials)
  usr = User.user_with_token(user_id)
  if usr.nil?
    usr = User.new()
    usr.token = user_id
  end

  usr.access_token  = credentials.access_token
  usr.refresh_token = credentials.refresh_token
  usr.expires_in    = credentials.expires_in
  usr.issued_at     = credentials.issued_at
  usr.save
end


configure do
  enable :sessions

  client                              = Google::APIClient.new
  client.authorization.client_id      = CLIENT_ID
  client.authorization.client_secret  = CLIENT_SECRET
  client.authorization.scope          = SCOPES

  mirror = client.discovered_api('mirror', 'v1')
  oauth2 = client.discovered_api('oauth2', 'v2')

  set :api_client, client
  set :mirror_api, mirror
  set :oauth2_api, oauth2
end


before do
  # Ensure user has authorized the app
  @has_token    = true
  @has_service  = true
  unless user_credentials.access_token || request.path_info =~ /^\/oauth2/ || request.path_info =~ /^\/notify/
     @has_token = false
  end

end

after do
  session[:access_token]  = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in]    = user_credentials.expires_in
  session[:issued_at]     = user_credentials.issued_at
end


def bootstrap_user
  subscribe_to_notification('timeline', to('/notify'))

  # Send them a hello Timeline card
  insert_contact(api_client, APP_NAME + "_welcome", APP_NAME, APP_IMAGE_URL)
  text = "Welcome to #{APP_NAME}"
  timeline_item = mirror_api.timeline.insert.request_schema.new({ 'text' => text, 'menuItems' => menuItems })

  optns = {}
  insert_timeline_item(timeline_item, optns)
end


get '/oauth2authorize' do
  redirect user_credentials.authorization_uri.to_s, 303
end


get '/oauth2callback' do
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  user_info = get_user_info
  session[:user_id] = user_info.id
  store_credentials user_info.id, user_credentials
  bootstrap_user

  redirect to('/')
end


get '/' do
  @has_service   = true
  user_id   = session[:user_id]
  usr       = User.user_with_token(user_id)
  if usr.nil? || usr.service_token.nil?
    @has_service = false
  end

  @token    = session[:user_id]
  @creds    = PP.pp(user_credentials,"")
  erb :index
end


get '/service-setup' do
  redirect to(service_auth_url)
end

# Pass this URL as the oAuth callback url for
# whatever service you want to authorize
get '/service-callback' do
  user_code = params[:code]
  access_token_url = service_auth_object.url_for_access_token(user_code)

  require 'open-uri'
  file = open(access_token_url)
  response_string = file.read

  if response_string
    usr = User.user_with_token(session[:user_id])

    access_token    = nil #parse the access token out of the response here
    expires_at_val  = nil #parse the expires in value out here

    usr.service_token = access_token
    usr.service_token_expires_at = expires_at_val
    usr.save
    redirect to('/')
  else
    "Something went wrong :("
  end
end


# Convenience endpoint if you want to get rid of the app
get '/uninstall' do
  client = new_google_client
  unsubscribe_from_notifications(api_client, 'timeline')
end


get '/subscribe' do
  subscribe_to_notification('timeline', to('/notify'))
end

# This is hit with a POST when the user shares something
# on their Glass device.
# The POST contains the properties described in 'notification'
# https://developers.google.com/glass/v1/reference/subscriptions
post '/notify' do
  params  = JSON.parse(request.env["rack.input"].read)

  # Store the notification, mainly just for reference
  # If you're getting a lot of notifications, you may
  # want to disable this
  notif   = Notification.new()
  notif.payload = PP.pp(params , '')
  notif.save

  userToken   = params["userToken"]
  item_id     = params["itemId"]

  # let's just ignore anything that's not
  # a new card... for now :)
  # valid options: INSERT, DELETE, UPDATE
  # https://developers.google.com/glass/v1/reference/subscriptions
  if !params["operation"].eql?('INSERT')
    status 200
    return
  end

  client      = new_google_client
  auth        = api_client.authorization.dup
  usr         = User.user_with_token(userToken)

  # Set up the app to use the user who the notification
  # came in from so any shares etc.. happen as them and
  # we can get access to their attachments etc..
  auth.redirect_uri = to('/oauth2callback')
  auth.update_token!({:access_token => usr.access_token,
    :refresh_token => usr.refresh_token,
    :expires_in => usr.expires_in,
    :issued_at => usr.issued_at})

  @authorization = auth

  if(item_id)

    mirror          = client.discovered_api('mirror', 'v1')
    attachment      = get_first_attachment(client, item_id)
    attachment_data = get_attachment_data(client, attachment)

    # If we didn't get an attachment, just die.
    if(attachment_data.nil?)
      return
    end

    timestamp       = Time.now.utc.iso8601.gsub('-', '').gsub(':', '')

    is_video = attachment.content_type.start_with?("video")
    if is_video
      filename        = userToken + timestamp + '.mp4'
    else
      filename        = userToken + timestamp + '.jpg'
    end

    file_url = upload_data_to_s3(attachment_data, filename)

    if is_video
      share_action_video(file_url, usr.service_token)
    else
      share_action(file_url, usr.service_token)
    end
    return ""
  end

end

end