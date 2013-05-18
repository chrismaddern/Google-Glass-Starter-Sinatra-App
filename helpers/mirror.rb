require 'sinatra/base'
require './models/user'

module Sinatra
  module MirrorHelper
    CLIENT_ID             = 'YOUR_GOOGLE_API_CLIENT_ID'
    CLIENT_SECRET         = 'YOUR_GOOGLE_CLIENT_SECRET'
    SCOPES = [
    'https://www.googleapis.com/auth/glass.timeline',
    'https://www.googleapis.com/auth/userinfo.profile',
]

def new_google_client
  client                              = Google::APIClient.new
  client.authorization.client_id      = CLIENT_ID
  client.authorization.client_secret  = CLIENT_SECRET
  client.authorization.scope          = SCOPES

  client
end

def user_credentials
  # Build a per-request oauth credential based on token stored in session
  # which allows us to use a shared API client.
  @authorization ||= (
    auth = api_client.authorization.dup
    if !session[:user_id].nil?
      usr = User.user_with_token(session[:user_id])
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!({:access_token => usr.access_token,
        :refresh_token => usr.refresh_token,
        :expires_in => usr.expires_in,
        :issued_at => usr.issued_at})
      auth
    else
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
    end
    auth
    )
end

def get_user_info
  result = api_client.execute!(api_method: oauth2_api.userinfo.get,
   authorization: user_credentials)
  user_info = nil
  if result.status == 200
    user_info = result.data
    puts user_info
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
  user_info
end

def insert_card_with_text(text)
  menuItems = []
  menuItems << { 'action' => 'DELETE' }
  timeline_item = mirror_api.timeline.insert.request_schema.new({ 'text' => text, 'menuItems' => menuItems })

  insert_timeline_item(
    timeline_item,
    {})
end

def insert_timeline_item(timeline_item, opts)
  if opts[:filename]
    media   = Google::APIClient::UploadIO.new(opts[:filename], opts[:content_type])
    result  = api_client.execute(
      api_method: mirror_api.timeline.insert,
      body_object: timeline_item,
      media: media,
      parameters: {
        'uploadType' => 'multipart',
        'alt' => 'json'},
        authorization: user_credentials)
  else
    result = api_client.execute(
      api_method: mirror_api.timeline.insert,
      body_object: timeline_item,
      authorization: user_credentials)
  end
  if result.success?
    result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end

def subscribe_to_notification(collection, callback_url)
  subscription = mirror_api.subscriptions.insert.request_schema.new({
    'collection'  => collection,
    'userToken'   => session[:user_id],
    'callbackUrl' => callback_url
    })

  result = api_client.execute(
    api_method:     mirror_api.subscriptions.insert,
    body_object:    subscription,
    authorization:  user_credentials)

  if result.error?
    "An error occurred: #{result.data['error']['message']}"
  else
    "#{PP.pp(result,'')}"
  end
end

def insert_contact(client, contact_id, display_name, image_url)
  mirror  = client.discovered_api('mirror', 'v1')
  contact = mirror.contacts.insert.request_schema.new({
    'id' => contact_id,
    'displayName' => display_name,
    'imageUrls' => [image_url]
    })
  result = client.execute(
    :api_method   => mirror.contacts.insert,
    :body_object  => contact,
    authorization: user_credentials)
  if result.success?
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end

def unsubscribe_from_notifications(client, collection)
  mirror = client.discovered_api('mirror', 'v1')
  result = client.execute(
    :api_method => mirror.subscriptions.delete,
    :parameters => { 'id' => collection },
    authorization: user_credentials)
  if result.error?
    "An error occurred: #{result.data['error']['message']}"
  else
    "#{PP.pp(result.data,'')}"
  end
end


def upload_data_to_s3(data, name)
  AWS::S3::Base.establish_connection!(
    :access_key_id     => settings.s3_key,
    :secret_access_key => settings.s3_secret)
  AWS::S3::S3Object.store(name,data, settings.bucket,:access => :public_read)
  return 'http://' + settings.bucket + '.s3.amazonaws.com/' + name
end

def get_first_attachment(client, item_id)
  mirror = client.discovered_api('mirror', 'v1')
  result = client.execute(
    :api_method     => mirror.timeline.attachments.list,
    :parameters     => { 'itemId' => item_id },
    :authorization  => user_credentials
    )

  if result.success?
    attachments = result.data
    if(attachments.items.first.is_processing_content)
      sleep 1
      return get_first_attachment(client, item_id)
    else
      return attachments.items.first
    end
  else
    nil
  end
end

def get_attachment_data(client, attachment)
  if(attachment.nil?)
    return nil
  end

  result = client.execute(:uri => attachment.content_url,
    :authorization  => user_credentials)
  if result.success?
    return result.body
  else
    puts "An error occurred: #{attachment.content_url}"
  end
end

end


helpers MirrorHelper
end