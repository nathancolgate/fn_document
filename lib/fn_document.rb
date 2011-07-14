Dir[File.dirname(__FILE__) + "/fn/**/*.rb"].each do |f|
  require f.sub(/\.rb/, '')
end