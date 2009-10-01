Gem::Specification.new do |s| 
  s.name = "career_builder" 
  s.version = "0.0.3" 
  s.author = "Dusty Doris" 
  s.email = "github@dusty.name" 
  s.homepage = "http://code.dusty.name" 
  s.platform = Gem::Platform::RUBY
  s.description = "Interface to Career Builder's API" 
  s.summary = "Interface to Career Builder's API" 
  s.files = [
    "README.txt",
    "lib/career_builder.rb",
    "lib/career_builder/client.rb",
    "lib/career_builder/models.rb",
    "lib/career_builder/parsers.rb",
    "test/test_career_builder.rb"
  ]
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README.txt"]
  s.add_dependency('noko_parser')
  s.add_dependency('patron')
  s.rubyforge_project = "none"
end
