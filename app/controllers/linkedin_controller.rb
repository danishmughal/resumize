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
  	require 'docx_templater'

  	init_client
    @c = session[:linkedin_client]

    # Getting the name, contact number, summary
    @profile1 = @c.profile(:fields=>["first_name","last_name","summary","date-of-birth","main_address","phone-numbers","primary-twitter-account","twitter-accounts","location"])
    @profile1 = @profile1.to_hash
	    @user_name = @profile1["first_name"] + " " + @profile1["last_name"]
	    @user_contact = @profile1["phone_numbers"]["all"].first["phone_number"]
	    @user_summary = @profile1["summary"]

    # Getting 3 jobs and their descriptions, etc.
    @profile2 = @c.profile(:fields=>["positions","three_current_positions","three_past_positions"])
    @profile2 = @profile2.to_hash
	    @user_job_1 = @profile2["positions"]["all"].first["company"]["name"]
	    @user_job_1_title = @profile2["positions"]["all"].first["title"]
	    @user_job_1_summary = @profile2["positions"]["all"].first["summary"]

	    @user_job_2 = @profile2["positions"]["all"].second["company"]["name"]
	    @user_job_2_title = @profile2["positions"]["all"].second["title"]
	    @user_job_2_summary = @profile2["positions"]["all"].second["summary"]

	    @user_job_3 = @profile2["positions"]["all"].third["company"]["name"]
	    @user_job_3_title = @profile2["positions"]["all"].third["title"]
	    @user_job_3_summary = @profile2["positions"]["all"].third["summary"]

	  # Getting education and skills of the user
    @profile3 = @c.profile(:fields=>["skills","educations"])
    @profile3 = @profile3.to_hash
    	@user_school = @profile3["educations"]["all"].first["school_name"]
    	@user_graduationyear = @profile3["educations"]["all"].first["end_date"]["year"]
    	@user_degree = @profile3["educations"]["all"].first["degree"] + " - " + @profile3["educations"]["all"].first["field_of_study"]

    	@user_skills = @profile3["skills"]["all"][0..8]


    # Some placeholder variables for document generation:
		location1_1 = '1'
		dates1_1 = '1'

		location1_2 = '2'
		dates1_2 = '2'

		location1_3 = '3'
		dates1_3 = '3'

		location2_1 = '1'
		dates2_1 = '1'

  	source = 'app/assets/docs/template/template.docx'
		buffer = DocxTemplater.new.replace_file_with_content(source,
		  {
        :NAME => @user_name, 
        :CONTACT => @user_contact, 
        :SUMMARY => @user_summary, 

        :Heading1 => "Work Experience",
        :Title11 => @user_job_1_title,
        :Description11 => @user_job_1_summary,
        :Location11 => location1_1,
        :Dates11 => dates1_1,

        :Title12 => @user_job_2_title,
        :Description12 => @user_job_2_summary,
        :Location12 => location1_2,
        :Dates12 => dates1_2,

        :Title13 => @user_job_3_title,
        :Description13 => @user_job_3_summary,
        :Location13 => location1_3,
        :Dates13 => dates1_3,

        :Heading2 => "Education",
        :Title21 => @user_school,
        :Description21 => @user_degree,
        :Location21 => location2_1,
        :Dates21 => @user_graduationyear,

        :Heading3 => "Skills",
        :Title31 => @user_skills[0]["skill"]["name"],
        :Title32 => @user_skills[1]["skill"]["name"],
        :Title33 => @user_skills[2]["skill"]["name"],
        :Title34 => @user_skills[3]["skill"]["name"],
        :Title35 => @user_skills[4]["skill"]["name"],
        :Title36 => @user_skills[5]["skill"]["name"],
        :Title37 => @user_skills[6]["skill"]["name"],
        :Title38 => @user_skills[7]["skill"]["name"],

 		  })
	
			# Sending the document to the user
			send_data buffer.string, :filename => 'YourResume.docx'


  end

  def download

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
