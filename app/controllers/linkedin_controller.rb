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
  	generate_doc
  end

  def generate_doc
  	source = 'app/assets/docs/template/template.docx'
		destination = 'app/assets/docs/output/resume.docx'
		FileUtils.cp source, destination
  end
 
  def download
  	send_file("#{Rails.root}/app/assets/docs/template/template.docx")
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

end
