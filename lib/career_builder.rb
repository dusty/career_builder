require 'noko_parser'
require 'patron'
require 'cgi'
module CareerBuilder
  
  def self.version
    "0.0.3"
  end
  ##
  # The API Key should be set
  # API_KEY = "xxxxxxxxxxxxxxx"
  
  ##
  # If test is not passed to apply, it will use the default
  # set in TEST_MODE
  # TEST_MODE = ""
  
  class ApiError < StandardError; end
    
end

require File.join(
  File.expand_path(File.dirname(__FILE__)), 'career_builder', 'parsers'
)
require File.join(
  File.expand_path(File.dirname(__FILE__)), 'career_builder', 'models',
)
require File.join(
  File.expand_path(File.dirname(__FILE__)), 'career_builder', 'client'
)
