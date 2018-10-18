class SecretsPolicy
  include Inesita::Component
  include Policy

  def render
  	div.wrapper do
      render_footer do
        div.control_wrapper do
          render_numeric_control :secrets, 'Number of Secrets:'
          render_numeric_control :annotations_per_secret, 'Annotations per Secret:'
        end
      end
	  render_policy
	end
  end
end