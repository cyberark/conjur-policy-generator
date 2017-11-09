task :tangle do
  mkdir_p 'src/ruby'
  system %Q{docker run --interactive --tty --rm --volume $(pwd):/workdir mqsoh/knot *.md src/*.md}
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:test)
rescue LoadError
end

task :generate, [:u, :g, :k] do |t, args|
  require_relative './src/ruby/generator'
  users = args[:u].to_i
  users = 2 if users <= 0
  groups = args[:g].to_i
  groups = 1 if groups <= 0
  usersPerGroup = args[:k].to_i
  usersPerGroup = 0 if usersPerGroup < 0
  human = Conjur::PolicyGenerator::Humans.new users, groups, usersPerGroup
  puts human.toMAML
end

task :version do
  system 'echo Conjur Policy Generator $(< VERSION)'
end
