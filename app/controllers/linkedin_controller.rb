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
  
    @name = @c.profile(:fields=>["first_name"])
  end

  def download
  	require 'docx_templater'
  	name = 'Ali Khan Afridi'
		contact = 'afridi2@illinois.edu'
		summary = 'Computer Science student interested in web and mobile development'

		heading1 = '1'
		title1_1 = '1'
		description1_1 = '1'
		location1_1 = '1'
		dates1_1 = '1'

		title1_2 = '2'
		description1_2 = '2'
		location1_2 = '2'
		dates1_2 = '2'

		title1_3 = '3'
		description1_3 = '3'
		location1_3 = '3'
		dates1_3 = '3'


		heading2 = '2'
		title2_1 = '1'
		description2_1 = '1'
		location2_1 = '1'
		dates2_1 = '1'


		heading3 = 'Skills'
		title3_1 ='Java / Android'
		title3_2 = 'C/C++'
		title3_3 ='Ruby'
		title3_4 = 'Version Control (Git/Svn)'
		title3_5 ='Arduino'
		title3_6 = 'HTML/CSS'
		title3_7 ='LaTeX'
		title3_8 = 'IBM SPSS'


		heading4 = 'Activities / Awards'
		title4_1 = 'ThinkChicago 2013'
		description4_1 = 'Invited by Mayor of Chicago to visit the city of chicago and meet the top innovators of the city'

		title4_2 = 'Beta Theta Pi'
		description4_2 = ''

		title4_3 = 'Campus 1871'
		description4_3 = ''

		heading5 = 'Activities / Awards'
		title5_1 = 'ThinkChicago 2013'
		description5_1 = 'Invited by Mayor of Chicago to visit the city of chicago and meet the top innovators of the city'

		title5_2 = 'Beta Theta Pi'
		description5_2 = ''

		title5_3 = 'Campus 1871'
		description5_3 = ''

  	source = 'app/assets/docs/template/template.docx'
		buffer = DocxTemplater.new.replace_file_with_content(source,
		  {
        :NAME => name, 
        :CONTACT => contact, 
        :SUMMARY => summary, 
        :Heading1 => heading1,
        :Title11 => title1_1,
        :Description11 => description1_1,
        :Location11 => location1_1,
        :Dates11 => dates1_1,
        :Title12 => title1_2,
        :Description12 => description1_2,
        :Location12 => location1_2,
        :Dates12 => dates1_2,
        :Title13 => title1_3,
        :Description13 => description1_3,
        :Location13 => location1_3,
        :Dates13 => dates1_3,
        :Heading2 => heading2,
        :Title21 => title2_1,
        :Description21 => description2_1,
        :Location21 => location2_1,
        :Dates21 => dates2_1,
        :Heading3 => heading3,
        :Title31 => title3_1,
        :Title32 => title3_2,
        :Title33 => title3_3,
        :Title34 => title3_4,
        :Title35 => title3_5,
        :Title36 => title3_6,
        :Title37 => title3_7,
        :Title38 => title3_8,
        :Heading4 => heading4,
        :Title41 => title4_1,
        :Description41 => description4_1,
        :Title42 => title4_2,
        :Description42 => description4_2,
        :Title43 => title4_3,
        :Description43 => description4_3,
        :Heading5 => heading5,
        :Title51 => title4_1,
        :Description51 => description5_1,
        :Title52 => title4_2,
        :Description52 => description5_2,
        :Title53 => title4_3,
        :Description53 => description5_3,
 		  })

		# Sending the document to the user
		send_data buffer.string, :filename => 'YourResume.docx'
		
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
