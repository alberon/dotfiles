# Install Gems into vendor/bundle instead of system directory
run "bundle install --path vendor/bundle --without production"

# Automatically enable mass assignment protection, for security
filename = "config/application.rb"
config = File.read filename
config.gsub! "# config.active_record.whitelist_attributes = true", "config.active_record.whitelist_attributes = true"
File.open(filename, "w") {|f| f << config }
