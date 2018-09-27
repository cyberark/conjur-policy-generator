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
          application_name: 'myapp',
          secret_groups: 1,
          secrets_per_group: 1,
          include_hostfactory: false
        },
        clamp: {
          secret_groups: [1, infinity],
          secrets_per_group: [1, infinity]
        }
      },
      humans: {
        generator: Conjur::PolicyGenerator::Humans,
        name: 'Humans & Groups',
        defaults: {
          users: 2,
          groups: 1,
          users_per_group: 1
        },
        clamp: {
          users: [1, infinity],
          groups: [0, infinity],
          users_per_group: [0, infinity]
        }
      },
      secrets: {
        generator: Conjur::PolicyGenerator::Secrets,
        name: 'Secrets Only',
        defaults: {
          secrets: 1,
          annotations_per_secret: 1
        },
        clamp: {
          secrets: [1, infinity],
          annotations_per_secret: [0, infinity]
        }
      },
    }
  end

  def change_generator new_generator
    raise unless supported_generators.include? new_generator
    @current_generator = new_generator
    @variables = supported_generators.dig(new_generator, :defaults).clone
  end

  def value variable
    @variables[variable]
  end

  def clamp variable, value
    bounds = supported_generators.dig(current_generator, :clamp, variable)
    return value if bounds.nil?
    value.clamp(*bounds)
  end

  def increase variable
    set variable, value(variable) + 1
  end

  def decrease variable
    set variable, value(variable) - 1
  end

  def set variable, value
    @variables[variable] = clamp(variable, value)
  end

  def policy_text
    supported_generators.dig(@current_generator, :generator)
      .new(*@variables.values)
      .toMAML
  end

  private

  def infinity
    Float::INFINITY
  end
end
