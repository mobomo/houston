Dir['lib/**/*.rb'].each {|core_ext| require core_ext[4..-4] }
