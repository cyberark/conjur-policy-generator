task :tangle do
  mkdir_p 'src/ruby'
  system %Q{docker run --interactive --tty --rm --volume $(pwd):/workdir mqsoh/knot *.md src/*.md}
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:test)
rescue LoadError
end
