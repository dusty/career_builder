module CareerBuilder

  class Client
    attr_accessor :zipcode, :radius, :job_search_parser, :job_parser,
                  :category_parser, :blank_application_parser,
                  :response_application_parser, :error_parser
  
    ##
    # Initialize the CareerBuilder API.  The API key is required, which must
    # be set in CareerBuilder::API_KEY.
    #
    # The zipcode and radius are set to limit results to a certain area.
    #
    # @params [:zipcode, :radius]
    #
    def initialize(params={})
      @zipcode = params[:zipcode]
      @radius  = params[:radius]
      unless CareerBuilder.const_defined?("API_KEY")
        raise ApiError, "CareerBuilder::API_KEY not found"
      end
      @http = Patron::Session.new
      @http.base_url = "http://api.careerbuilder.com/v1"
      reset_caches
    end

    ##
    # Get all the categories in Career Builder
    #
    # The answer is cached.  You may send :force => true to force a reload.
    #
    # @return [Array<Category>]
    def categories(params={})
      return @categories if (@categories && !params[:force])
      @categories = get_categories
    end

    ##
    # Get all the categories in Career Builder returned as a Hash
    # with the format of {:code => :name}.  This can be used for
    # quick translations
    #
    # eg: categories_hash['JN001'] # "Accounting"
    #
    # The answer is cached.  You may send :force => true to force a reload.
    #
    # @return [Hash]
    def categories_hash(params={})
      return @categories_hash if (@categories_hash && !params[:force])
      @categories_hash = get_categories_hash
    end

    ##
    # Get all the jobs in a certain location.  This is based on a zipcode
    # and then a radius around that zipcode in miles.
    #
    # You may specify :page and :per_page in the params hash.  The answer
    # is cached.  You may send :force => true to force a reload.
    #
    # @return [Array<Job>]
    def jobs(params={})
      @radius = params[:radius] if params[:radius]
      @zipcode = params[:zipcode] if params[:zipcode]
      return @jobs if (@jobs && !params[:force])
      page = params[:page] || 1
      per_page = params[:per_page] || 100
      @jobs = get_jobs(page,per_page)
    end
    
    ##
    # Get all the jobs in a certain category and location.  This is based
    # on a zipcode and then a radius around the zipcode in miles
    #
    # You may specify :page and :per_page in the params hash.  The answer
    # is cached.  You may send :force => true to force a reload.
    #
    # @return [Array<Job>]
    def category_jobs(category,params={})
      @radius = params[:radius] if params[:radius]
      @zipcode = params[:zipcode] if params[:zipcode]
      if (@category_jobs[extract_category(category)] && !params[:force])
        return @category_jobs[extract_category(category)]
      end
      page = params[:page] || 1
      per_page = params[:per_page] || 100
      @category_jobs[extract_category(category)] = get_category_jobs(
        category,page,per_page
      )
    end
  
    ##
    # Get detailed information about a job
    #
    # The answer is cached.  You may send :force => true to force a reload.
    #
    # @return [Job]
    def job(job,params={})
      if (@job[extract_job(job)] && !params[:force])
        return @job[extract_job(job)]
      end
      @job[extract_job(job)] = get_job(job)
    end
    
    ##
    # Get the application requirements for a job.  
    #
    # The answer is cached.  You may send :force => true to force a reload.
    #
    # @return [BlankApplication]
    def application(job,params={})
      if (@application[extract_job(job)] && !params[:force])
        return @application[extract_job(job)]
      end
      @application[extract_job(job)] = get_application(job)
    end
    
    ##
    # Apply for the job.
    #
    # @return [ResponseApplication]
    def apply(application, params={})
      response = @http.post("/application/submit", application.to_xml)
      check_status(response)
      response_application_parser.parse(response.body).first
    end
    
    ##
    # Apply for the job, forcing test mode.
    #
    # @see apply
    def apply_test(application)
      application.test = true
      apply(application)
    end
    
    ##
    # Set the zipcode to use for job searches.  Resets the caches
    # assuming user wants fresh answers
    def zipcode=(_zipcode)
      reset_caches unless @zipcode == _zipcode
      @zipcode = _zipcode
    end
    
    ##
    # Set the radius to use for job searches.  Resets the caches
    # assuming user wants fresh answers
    def radius=(_radius)
      reset_caches unless @radius == _radius
      @radius = _radius
    end

    ##
    # Returns the set job_search_parser or the default
    def job_search_parser
      @job_search_parser || JobSearch
    end
    
    ##
    # Returns the set job_parser or the default
    def job_parser
      @job_parser || Job
    end
    
    ##
    # Returns the set category_parser or the default
    def category_parser
      @category_parser || Category
    end
    
    ##
    # Returns the set blank_application_parser or the default
    def blank_application_parser
      @blank_application_parser || BlankApplication
    end
    
    ##
    # Returns the set response_application_parser or the default
    def response_application_parser
      @response_application_parser || ResponseApplication
    end
    
    ##
    # Returns the set error_parser or the default
    def error_parser
      @error_parser || Error
    end
    
    private
  
    def default_params
      {:DeveloperKey => API_KEY}
    end
  
    def get_categories
      params = {"CountryCode" => "US"}
      response = do_get("/categories", params)
      category_parser.parse(response)
    end
    
    def get_categories_hash
      hash = {}
      categories(:force => true).each do |category| 
        hash.update(category.code => category.name)
      end
      hash
    end
    
    def get_jobs(page,per_page)
      results = []
      categories.each do |category|
        results += get_category_jobs(category,page,per_page)
      end
      merge_duplicates(results)
    end

    def get_category_jobs(category,page,per_page)
      unless zipcode && radius
        raise ApiError, "zipcode and radius are required."
      end
      params = {
        'Location' => zipcode,
        'Radius' => radius,
        'PostedWithin' => '1',
        'PerPage' => per_page,
        'PageNumber' => page,
        'Category' => extract_category(category)
      }
      jobs = job_search_parser.parse(do_get("/jobsearch", params))
      add_category_to_jobs(category,jobs)
    end
    
    def get_application(job)
      params = {'JobDID' => extract_job(job)}
      response = do_get('/application/blank', params)
      blank_application_parser.parse(response).first
    end
    
    def get_job(job)
      params = {'DID' => extract_job(job)}
      response = do_get('/job', params)
      job_parser.parse(response).first
    end

    def do_get(path,params)
      response = @http.get("#{path}#{to_query(params)}")
      check_status(response)
      check_errors(response)
      response.body
    end
  
    def to_query(params={})
      output = default_params.update(params).map do |key, value|
        "#{key}=#{CGI.escape(value.to_s)}"
      end.join("&")
      "?#{output}"
    end

    def check_status(response)
      unless response.status == 200
        raise ApiError, "Response Code: #{response.status}" 
      end
    end
    
    def check_errors(response)
      errors = error_parser.parse(response.body)
      unless errors.empty?
        raise ApiError, "Error #{errors.first.message}"
      end
    end
    
    def extract_category(category)
      category.is_a?(String) ? category : category.code
    end
    
    def extract_job(job)
      job.is_a?(String) ? job : job.id
    end
    
    def reset_caches
      @categories = nil
      @categories_hash = nil
      @jobs = nil
      @job = {}
      @category_jobs = {}
      @application = {}
    end
    
    ##
    # Since Career Builder doesn't give the job category in information
    # in the search API, we need to add the category to each job after
    # the fact.
    #
    def add_category_to_jobs(category,jobs)
      jobs.each {|j| j.categories = [category]}
      jobs
    end
    
    ##
    # We are going to loop through each job and find duplicates
    # based on the job id.  The first job will remain with the categories
    # of the other jobs added to it
    #
    # This is a hack since Career Builder doesn't give job category
    # information in the search API.
    def merge_duplicates(jobs)
      job_hash = {}
      jobs.each do |job|
        if job_hash[job.id]
          job_hash[job.id].categories.push(job.categories.first)
        else
          job_hash[job.id] = job
        end
      end
      job_hash.values
    end
    
  end
end