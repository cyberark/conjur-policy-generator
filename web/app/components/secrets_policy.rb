class SecretsPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    render_footer do
      render_numeric_control :secrets, 'Number of secrets:'
      render_numeric_control :annotations_per_secret, 'Annotations per secret:'
    end
  end
end
