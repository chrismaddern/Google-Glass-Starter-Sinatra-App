#Google Glass Mirror API Ruby / Sinatra Scaffolding App

Scaffold for creating Google Glass Mirror API apps in Ruby on Sinatra. 
This was created while making Facebook for Glass - https://facebookglass.herokuapp.com and makes it simple to connect to Glass and one other service and to send items from Glass to that other service.

##Getting Started

This project relies on a local Postgres database. 
Create a local database and head in to `config/database.yml` to configure the app for your database.

Fire it up:
`bundle exec unicorn`

You should see something like this:
![ScreenShot](http://www.chrismaddern.com/images/google-glass-mirror-app-screen.png)

Now at the top of `application.rb`, edit the following:

  ```ruby
  APP_NAME        = "YOUR_APP_NAME"
  APP_IMAGE_URL   = "YOUR_APP_IMAGE_URL"
  SERVICE_NAME    = "SERVICE_NAME"

  set :bucket,      'YOUR_S3_BUCKET'
  set :s3_key,      'YOUR_S3_KEY'
  set :s3_secret,   'YOUR_S3_SECRET'
  ```
Open `helpers/yourservicehelper.rb` and implement the following methods:

```ruby
  def service_auth_url
  def service_auth_object # an oauth object representing the connection to the service you're using
  def share_action(img_url, access_token)
  def share_action_video(img_url, access_token)
```

You should now have a very basic Glass application that will authorize with Glass & your service and can start implementing new features!


##Learn More

The Mirror API developer reference is a great resource and has the answers to most questions
https://developers.google.com/glass/v1/reference/

Feel free to drop me an email (chris - at- applaunch.us) if you have questions or open a Git Issue.

##License

This project is released under the MIT license. Please feel free to use & extend it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
