task :tangle do
  mkdir_p 'src/ruby'
  file_list = Rake::FileList['src/ruby/*.rb']
  rm_f file_list unless file_list.length == 0
  system %Q{docker run -it --rm -v $(pwd):/workdir mqsoh/knot *.md src/*.md}
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

task :secrets, [:v, :a] do |t, args|
  require_relative './src/ruby/generator'
  variables = args[:v].to_i
  variables = 1 if variables <= 0
  annotations = args[:a].to_i
  annotations = 0 if annotations <= 0
  secrets = Conjur::PolicyGenerator::Secrets.new variables, annotations
  puts secrets.toMAML
end

task :control_secrets,
     [:name, :groups, :secrets_per_group, :include_hostfactory] do |t, args|
  require_relative './src/ruby/generator'
  name = args[:name]
  secret_groups = args[:groups].to_i
  secrets_per_group = args[:secrets_per_group].to_i
  include_hostfactory = args[:include_hostfactory].to_s.downcase == 'true'
  secret_control = Conjur::PolicyGenerator::Template::
                     SecretControl.new name,
                                       secret_groups,
                                       secrets_per_group,
                                       include_hostfactory
  puts secret_control.toMAML
end

task :k8s,
     [:app_name, :app_namespace, :authenticator_id] do |t, args|
  require_relative './src/ruby/generator'
  app_name = args[:app_name]
  app_namespace = args[:app_namespace]
  authenticator_id = args[:authenticator_id]
  kubernetes_generator = Conjur::PolicyGenerator::Template::Kubernetes.new app_name,
                                                                           app_namespace,
                                                                           authenticator_id
  puts kubernetes_generator.toMAML
end

task :version do
  system 'echo Conjur Policy Generator $(cat VERSION)'
end
