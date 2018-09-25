require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'linkedin'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => 'https://api.linkedin.com',
        :authorize_url => 'https://www.linkedin.com/oauth/v2/authorization?response_type=code',
        :token_url => 'https://www.linkedin.com/oauth/v2/accessToken'
      }

      ID_FIELD_KEY = 'id'
      FIRST_NAME_FIELD_KEY = 'firstName'
      LAST_NAME_FIELD_KEY = 'lastName'
      HEADLINE_FIELD_KEY = 'headline'
      VANITY_NAME_FIELD_KEY = 'vanityName'
      LOCATION_FIELD_KEY = 'location'
      INDUSTRY_ID_FIELD_KEY = 'industryId'

      # These fields are not standard linkedin profile fields
      # But it's an easy way to get users to specify they want these fields
      EMAIL_ADDRESS_FIELD_KEY = 'emailAddress'
      PROFILE_PICTURE_URL_FIELD_KEY = 'profilePictureUrl'


      PROFILE_PICTURE_URL_FIELD_VALUE = 'profilePicture(displayImage~:playableStreams)'

      option :scope, 'r_basicprofile r_emailaddress'
      option :fields, [
        ID_FIELD_KEY,
        FIRST_NAME_FIELD_KEY,
        LAST_NAME_FIELD_KEY,
        HEADLINE_FIELD_KEY,
        VANITY_NAME_FIELD_KEY,
        LOCATION_FIELD_KEY,
        INDUSTRY_ID_FIELD_KEY,

        # not standard linked
        EMAIL_ADDRESS_FIELD_KEY,
        PROFILE_PICTURE_URL_FIELD_KEY]


      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info[ID_FIELD_KEY] }

      info do
        {
          :name => user_name,
          :email => email_address,
          :nickname => user_name,
          :first_name => raw_info[FIRST_NAME_FIELD_KEY],
          :last_name => raw_info[LAST_NAME_FIELD_KEY],
          :location => raw_info[LOCATION_FIELD_KEY],
          :description => raw_info[HEADLINE_FIELD_KEY],
          :image => profile_image,
          :urls => {
            'public_profile'.freeze => public_profile_url
          }
        }
      end

      extra do
        { 'raw_info'.freeze => raw_info }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      alias :oauth2_access_token :access_token

      def access_token
        ::OAuth2::AccessToken.new(client, oauth2_access_token.token, {
          mode: :query,
          param_name: 'oauth2_access_token'.freeze,
          expires_in: oauth2_access_token.expires_in,
          expires_at: oauth2_access_token.expires_at,
          # TODO check this is working
          # https://developer.linkedin.com/docs/guide/v2/concepts/protocol-version
          "X-RestLi-Protocol-Version".freeze => "2.0.0"
        })
      end

      def raw_info
        @raw_info || do
          encoded_params = CGI.escape("projection=(#{option_fields.join(',')})")
          access_token.get("/v2/me?#{encoded_uri}").parsed
        end
      end

      private

      def option_fields
        options.fields.
          delete(EMAIL_ADDRESS_FIELD_KEY).
          replace(PROFILE_PICTURE_URL_FIELD_KEY, PROFILE_PICTURE_URL_FIELD_VALUE)
      end

      def user_name
        name = "#{raw_info[FIRST_NAME_FIELD_KEY]} #{raw_info[LAST_NAME_FIELD_KEY]}".strip
        name.empty? ? nil : name
      end

      def public_profile_url
        if raw_info[VANITY_NAME_FIELD_KEY].present?
          "www.linkedin.com/in/#{raw_info[VANITY_NAME_FIELD_KEY]}"
        end
      end

      def profile_image
        info_profile_picture = raw_info['profilePicture'.freeze]
        if info_profile_picture.present?
          # TODO not sure about what happens here
          # https://developer.linkedin.com/docs/ref/v2/profile/profile-picture
          info_profile_picture['displayImage~:playableStreams'.freeze]
          # or
          # info_profile_picture['displayImage~']['elements']['identifies'].first['indentifier']
        end
      end

      def email_address
        if fields.include?(EMAIL_ADDRESS_FIELD_KEY)
          # https://developer.linkedin.com/docs/guide/v2/people/primary-contact-api#email
          # TODO not sure what gets returned
          handles = access_token.get("/v2/clientAwareMemberHandles?q=members&projection=(elements*(primary,type,handle~))").parsed
          handles.each do |handle|
            if handle["type".freeze] == "EMAIL".freeze
              return handle["handle~".freeze]["emailAddress".freeze]
            end
          end

          # return nil if email handle not found
          nil
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'linkedin', 'LinkedIn'
