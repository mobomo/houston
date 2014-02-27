desc "Seed projects from current database"
task :get_projects => :environment do
  puts "Finding projects"
  Project.init_or_update_raw_data
  puts "done."
end
