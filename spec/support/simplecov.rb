require 'simplecov'

SimpleCov.start 'rails' do
  track_files 'app/controllers/**/*.rb'
  track_files 'app/services/**/*.rb'
  track_files 'app/models/**/*.rb'
end
