task :tangle do
  mkdir_p 'src/ruby'
  system %Q{docker run --interactive --tty --rm --volume $(pwd):/workdir mqsoh/knot *.md src/*.md}
end

task :test => :tangle do
  require_relative 'src/ruby/generator'
  include Conjur::PolicyGenerator

  humans = Humans.new
  puts humans.toMAML
end
