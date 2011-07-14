Dir[File.dirname(__FILE__) + "/fn/**/*.rb"].each do |f|
  require_dependency f.sub(/\.rb/, '')
end