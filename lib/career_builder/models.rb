module CareerBuilder
  
  class Category
    include CareerBuilder::Parsers::Category
  end

  class ResponseApplication
    include CareerBuilder::Parsers::ResponseApplication
  end
  
  class BlankApplication
    include CareerBuilder::Parsers::BlankApplication
  end

  class Question
    include CareerBuilder::Parsers::Question
  end
  
  class Answer
    include CareerBuilder::Parsers::Answer
  end

  class JobSearch
    include CareerBuilder::Parsers::JobSearch
  end
  
  class Job
    include CareerBuilder::Parsers::Job
  end
  
  class Error
    include CareerBuilder::Parsers::Error
  end
  
  class Money
    include CareerBuilder::Parsers::Money
  end

  class RequestApplication
    attr_accessor :job_id, :test, :responses
    def initialize(params={})
      @job_id = params[:job_id]
      @test = params[:test] || false
      @responses = params[:responses] || []
    end
    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.RequestApplication {
          xml.DeveloperKey CareerBuilder::API_KEY
          xml.JobDID job_id
          xml.Test self.test.to_s.capitalize
          xml.Responses {
            self.responses.each do |r|
              xml.Response {
                xml.QuestionID r.question_id
                xml.ResponseText r.response_text
              }
            end
          }
        }
      end
      builder.to_xml
    end
  end
  
  class Response
    attr_accessor :question_id, :response_text
    def initialize(params={})
      @question_id = params[:question_id]
      @response_text = params[:response_text]
    end
  end
  
end