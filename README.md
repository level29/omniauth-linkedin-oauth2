# OmniAuth LinkedIn OAuth2 Strategy

This project has been forked from https://github.com/decioferreira/omniauth-linkedin-oauth2

It has changed from using the Linkedin API v1 to use API v2 for retrieving
member's details.

For more details, read the LinkedIn documentation: https://developer.linkedin.com/docs/oauth2

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-linkedin-oauth2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-linkedin-oauth2

# Usage

Register your application with LinkedIn to receive an API key: https://www.linkedin.com/secure/developer

This is an example that you might put into a Rails initializer at `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
end
```

You can now access the OmniAuth LinkedIn OAuth2 URL: `/auth/linkedin`.

## Granting Member Permissions to Your Application

With the LinkedIn API, you have the ability to specify which permissions you want users to grant your application.
For more details, read the LinkedIn documentation: https://developer.linkedin.com/docs/guide/v2

By default, omniauth-linkedin-oauth2 requests the following permissions:

    'r_basicprofile r_emailaddress'

You can configure the scope option:

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :scope => 'r_fullprofile r_network'
```

## Profile Fields

When specifying which permissions you want users to grant to your application, you will probably want to specify the array of fields that you want returned in the omniauth hash. The list of default fields is as follows:

```ruby
['id', 'firstName', 'lastName', 'headline', 'location', 'industryId', 'emailAddress', 'profilePicture']
```

`emailAddress` and `profilePictureUrl` are not profile fields, but can be added like this to make it simpler to request this data.

Here's an example of a possible configuration where the fields returned from the API are: id, firstName and lastName.

```ruby
provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], :fields => ['id', 'firstName', 'lastName']
```

To see a complete list of available fields, consult the LinkedIn documentation at: https://developer.linkedin.com/docs/ref/v2/profile/basic-profile


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
