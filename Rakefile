require "bundler"
Bundler.setup :development

Dir.glob("tasks/*.rake").each do |file|
  load file
end

task :default => :test

# Add "rake release and rake install"
Bundler::GemHelper.install_tasks

task :default => [:test, :rdoc]
