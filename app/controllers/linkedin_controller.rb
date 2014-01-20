class LinkedinController < ApplicationController
	def init_client
    key = "75ez6rimnpjw07"
    secret = "gZAiFn5RkLpk0k1k" 
    linkedin_configuration = { :site => 'https://api.linkedin.com',
        :authorize_path => '/uas/oauth/authenticate',
        :request_token_path =>'/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile+r_emailaddress+r_network+r_contactinfo',
        :access_token_path => '/uas/oauth/accessToken' }
    @linkedin_client = LinkedIn::Client.new(key, secret,linkedin_configuration )
  end
 
  def auth
    init_client
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
 
    c = @linkedin_client
    
    profile_1 = c.profile(:fields=>["first_name","last_name","headline","public_profile_url","date-of-birth","main_address","phone-numbers","primary-twitter-account","twitter-accounts","location"])
 
    puts "profile_1 = #{profile_1}"
 
    profile_2 = c.profile(:fields=>["positions","three_current_positions","three_past_positions","publications","patents"])
 
    puts "profile_2 = #{profile_2}"
 
    profile_3 = c.profile(:fields=>["languages","skills","certifications","educations"])
    
    puts "profile_3 = #{profile_3}"
 
 
    session[:atoken] = nil
    session[:asecret] = nil
    redirect_to root_path(:imported_from_linkedin=>"success")
  end

end
