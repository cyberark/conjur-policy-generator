class Home
  include Inesita::Component

  def render
    div.bg_light style: {'margin-bottom': '10rem'} do
      case store.current_generator
      when :secrets
        component SecretsPolicy
      when :humans
        component HumansPolicy
      else
        text "Error: can't show the policy (#{store.current_generator}, #{store.current_generator.class})"
      end
    end
  end
end
