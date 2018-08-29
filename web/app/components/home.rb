class Home
  include Inesita::Component

  def render
    case store.current_generator
    when 'secret_control'
      component SecretControlPolicy
    when 'secrets'
      component SecretsPolicy
    when 'humans'
      component HumansPolicy
    else
      text "Error: can't show the policy (#{store.current_generator}, #{store.current_generator.class})"
    end
  end
end
