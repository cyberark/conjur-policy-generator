class Store
  include Inesita::Injection

  def init
    change_generator :secrets
  end

  def supported_generators
    {
      humans: {
        generator: Conjur::PolicyGenerator::Humans,
        defaults: {
          users: 2,
          groups: 1,
          users_per_group: 1
        }
      },
      secrets: {
        generator: Conjur::PolicyGenerator::Secrets,
        defaults: {
          secrets: 1,
          annotations_per_secret: 1
        }
      }
    }
  end

  def change_generator new_generator
    raise unless supported_generators.include? new_generator
    @current_generator = new_generator
    @variables = supported_generators.dig(new_generator, :defaults).clone
  end

  def current_generator
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

  def policy_text
    current_generator.new(*@variables.values).toMAML
  end
end
