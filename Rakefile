require "bundler/gem_tasks"

# The compile command should depend on installing libssh2
#task :compile => ["ports:libssh2"]

# Load all the rak tasks from the "tasks" folder. This folder
# allows us to nicely separate rake tasks into individual files
# based on their role, which makes development and debugging easier
# than one monolithic file.
task_dir = File.expand_path("../tasks", __FILE__)
Dir["#{task_dir}/**/*.rake"].each do |task_file|
  load task_file
end
