require 'sinatra/base'

module Sinatra
  module YourShareHelper
    SERVICE_APP_ID    = 'YOUR_SERVICE_APP_ID'
    SERVICE_SECRET    = 'YOUR_SERVICE_SECRET'

    def service_auth_url
      # Construct the oAuth URL for your service here...
      ""
    end

    def service_auth_object
      # replace nil with your service's oAuth object
      @service_auth ||= nil
    end

    def base_url
      @base_url ||= "https://#{request.env['HTTP_HOST']}"
    end

    def share_action(img_url, access_token)
      # implement whatever you want to do with the image here
    end

    def share_action_video(img_url, access_token)
      # implement whatever you want to do with the video here
    end

  end

  helpers YourShareHelper
end