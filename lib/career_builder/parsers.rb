module CareerBuilder
  module Parsers
    
    module JobSearch
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//JobSearchResult'
          property :id, :xpath => 'DID'
          property :title, :xpath => 'JobTitle'
          property :description, :xpath => 'DescriptionTeaser'
          property :company, :xpath => 'Company'
          property :location, :xpath => 'Location'
          property :pay, :xpath => 'Pay'
          def categories
            @categories
          end
          def categories=(categories)
            @categories = categories
          end
        end
      end
    end # End JobSearchResult
    
    module Job
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Job'
          property :apply_url, :xpath => 'ApplyURL'
          property :external_application, :xpath => 'ExternalApplication'
          property :service_url, :xpath => 'ApplicationSubmitServiceURL'
          property :begin_date, :xpath => 'BeginDate'
          property :blank_application_url, 
            :xpath => 'BlankApplicationServiceURL'
          property :categories, :xpath => 'Categories'
          property :company, :xpath => 'Company'
          property :company_url, :xpath => 'CompanyDetailsURL'
          property :company_id, :xpath => 'CompanyDID'
          property :company_search_url, :xpath => 'CompanyJobSearchURL'
          property :company_image_url, :xpath => 'CompanyImageURL'
          property :contact_email_url, :xpath => 'ContactInfoEmailURL'
          property :contact_fax, :xpath => 'ContactInfoFax'
          property :contact_name, :xpath => 'ContactInfoName'
          property :contact_phone, :xpath => 'ContactInfoPhone'
          property :degree_required, :xpath => 'DegreeRequired'
          property :id, :xpath => 'DID'
          property :display_id, :xpath => 'DisplayJobID'
          property :employment_type, :xpath => 'EmploymentType'
          property :end_date, :xpath => 'EndDate'
          property :experience_required, :xpath => 'ExperienceRequired'
          property :description, :xpath => 'JobDescription'
          property :requirements, :xpath => 'JobRequirements'
          property :title, :xpath => 'JobTitle'
          property :street1, :xpath => 'LocationStreet1'
          property :street2, :xpath => 'LocationStreet2'
          property :city, :xpath => 'LocationCity'
          property :country, :xpath => 'LocationCountry'
          property :short_location, :xpath => 'LocationFormatted'
          property :latitude, :xpath => 'LocationLatitude'
          property :longitude, :xpath => 'LocationLongitude'
          property :metro, :xpath => 'LocationMetroCity'
          property :postal_code, :xpath => 'LocationPostalCode'
          property :state, :xpath => 'LocationState'
          property :manager, :xpath => 'ManagesOther'
          property :modifed_date, :xpath => 'ModifiedDate'
          embed :pay_high, :xpath => 'PayHigh', :single => true,
            :class => 'CareerBuilder::Money'
          embed :pay_low, :xpath => 'PayLow', :single => true,
            :class => 'CareerBuilder::Money'
          property :pay_period, :xpath => 'PayPer'
          property :pay_range, :xpath => 'PayHighLowFormatted'
          embed :commission, :xpath => 'PayCommission', :single => true,
            :class => 'CareerBuilder::Money'
          embed :bonus, :xpath => 'PayBonus', :single => true,
            :class => 'CareerBuilder::Money'
          property :other_pay, :xpath => 'PayOther'
          property :print_url, :xpath => 'PrinterFriendlyURL'
          property :relocation_covered, :xpath => 'RelocationCovered'
          property :travel_required, :xpath => 'TravelRequired'
        end
        def external_application?
          !!/true/i.match(external_application)
        end
        def categories
          @categories.split(',').map {|c| c.strip}
        end
        def location
          [
            street1, street2, city, state, 
            postal_code, country
          ].compact.join(", ")
        end
        def manager?
          !!/true/i.match(@manages_others)
        end
        def relocation_covered?
          !!/true/i.match(@relocation_covered)
        end
      end 
    end # End Job
    
    module ResponseApplication
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//ResponseApplication'
          property :status, :xpath => 'ApplicationStatus'
          embed :errors, :xpath => 'Errors', :class => 'CareerBuilder::Error'
          def complete?
            !!/^Complete/i.match(status)
          end
          def success?
            complete?
          end
          def errors?
            !errors.empty?
          end
        end
      end
    end
    
    module BlankApplication
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//BlankApplication'
          property :apply_url, :xpath => 'ApplyURL'
          property :service_url, :xpath => 'ApplicationSubmitServiceURL'
          property :job_id,  :xpath => 'JobDID'
          property :job_title, :xpath => 'JobTitle'
          property :total_questions, :xpath => 'TotalQuestions'
          property :total_required_questions, 
            :xpath => 'TotalRequiredQuestions'
          embed :questions, :xpath => 'Questions',
            :class => 'CareerBuilder::Question'
          def internal?
            !total_questions.nil?
          end
          def external?
            total_questions.nil?
          end
          def required_questions
            return nil unless questions
            questions.select { |question| question.required? }
          end
        end
      end
    end # End Application
    
    module Question
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Question'
          property :id, :xpath => 'QuestionID'
          property :type, :xpath => 'QuestionType'
          property :required, :xpath => 'IsRequired'
          property :format, :xpath => 'ExpectedResponseFormat'
          property :text, :xpath => 'QuestionText'
          embed :answers, :xpath => 'Answers',
            :class => 'CareerBuilder::Answer'
          def required?
            !!/true/i.match(@required)
          end
        end
      end
    end # End Question
    
    module Answer
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Answer'
          property :question_id, :xpath => 'QuestionID'
          property :id, :xpath => 'AnswerID'
          property :text, :xpath => 'AnswerText'
        end
      end
    end

    module Category
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Category'
          property :code, :xpath => 'Code'
          property :name, :xpath => 'Name'
        end
      end
    end # End Category
    
    module Error
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Error'
          property :message, :xpath => '.'
        end
      end
    end
    
    module Money
      def self.included(base)
        base.class_eval do
          include ::NokoParser::Properties
          nodes :xpath => '//Money'
          property :amount, :xpath => 'Amount'
          property :currency, :xpath => 'CurrencyCode'
          property :display_amount, :xpath => 'FormattedAmount'
          def amount
            @amount.to_f
          end
        end
      end
    end
    
  end # End Parsers
  
end # End CareerBuilder