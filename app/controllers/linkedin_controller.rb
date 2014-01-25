class LinkedinController < ApplicationController
	def init_client
    key = "75ez6rimnpjw07"
    secret = "gZAiFn5RkLpk0k1k" 
    linkedin_configuration = { :site => 'https://api.linkedin.com',
        :authorize_path => '/uas/oauth/authenticate',
        :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile+r_emailaddress+r_network+r_contactinfo',
        :access_token_path => '/uas/oauth/accessToken' }
    @linkedin_client = LinkedIn::Client.new(key, secret,linkedin_configuration)
  end

  def processed
  	init_client
    @c = session[:linkedin_client]
    @profile1 = @c.profile(:fields=>["first_name","last_name","headline","public_profile_url","date-of-birth","main_address","phone-numbers","primary-twitter-account","twitter-accounts","location"])
  end
 
  def auth
    init_client # Initialize settings defined above in the method
    request_token = @linkedin_client.request_token(:oauth_callback => "http://#{request.host_with_port}/linkedin/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @linkedin_client.request_token.authorize_url
  end
 
  def callback
    init_client
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret =  @linkedin_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      @linkedin_client.authorize_from_access(session[:atoken], session[:asecret])
    end
 
    session[:linkedin_client] = @linkedin_client
    redirect_to processed_path(:imported_from_linkedin=>"success")
  end

  def destroy
	  session[:atoken] = nil
    session[:asecret] = nil
  	session[:linkedin_client] = nil
  	redirect_to root_path
  end

  def doctest
  	require 'open-uri'

  	email = URI::encode("afridi2@illinois.edu")
  	password = URI::encode("tempword")

		@response = HTTParty.post("https://www.doccyapp.com/api/1/sessions.json?email=#{email}&password=#{password}")
		token = @response['response']['auth_token']
		account_id = @response['response']['account_id']

		@template = HTTParty.get("https://www.doccyapp.com/api/1/templates.json?auth_token=#{token}")
		template_id = @template['response'].first['template']['id']

		@documentresponse = HTTParty.post("https://www.doccyapp.com/api/1/templates/#{template_id}/documents.json", 
		    :body => { 
		    	:document => {
		               :name => 'Document name goes here', 
		               :content => {
		               		:name => 'Persons name', 
		               		:company => 'company goes here', 
		               	}
		      }
		    }.to_json,
		    :headers => { 'Content-Type' => 'application/json' } )

  end

end
