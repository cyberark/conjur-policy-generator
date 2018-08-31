class Store
  include Inesita::Injection
  attr_reader :current_generator
  attr_reader :supported_generators

  def init
    change_generator :secret_control
  end

  def supported_generators
    {
      secret_control: {
        generator: Conjur::PolicyGenerator::Template::SecretControl,
        name: 'Secret Control',
        defaults: {
          policy_name: 'myapp',
          secret_groups: 1,
          secrets_per_group: 1,
          include_hostfactory: false
        }
      },
      humans: {
        generator: Conjur::PolicyGenerator::Humans,
        name: 'Humans & Groups',
        defaults: {
          users: 2,
          groups: 1,
          users_per_group: 1
        }
      },
      secrets: {
        generator: Conjur::PolicyGenerator::Secrets,
        name: 'Secrets Only',
        defaults: {
          secrets: 1,
          annotations_per_secret: 1
        }
      },
    }
  end

  def change_generator new_generator
    raise unless supported_generators.include? new_generator
    @current_generator = new_generator
    @variables = supported_generators.dig(new_generator, :defaults).clone
  end

  def generator
    supported_generators.dig(@current_generator, :generator)
  end

  def value variable
    @variables[variable] = 0 if not @variables.include? variable
    @variables[variable]
  end

  def increase variable
    @variables[variable] = value(variable) + 1
  end

  def decrease variable
    @variables[variable] = value(variable) - 1
  end

  def set variable, value
    @variables[variable] = value
  end

  def policy_text
    generator.new(*@variables.values).toMAML
  end
end
