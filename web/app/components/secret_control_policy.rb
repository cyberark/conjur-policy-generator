class SecretControlPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    render_footer do
      render_text_control :policy_name, 'Policy name:'
      render_numeric_control :secret_groups, '# of secret groups:'
      render_numeric_control :secrets_per_group, 'Secrets per group:'
      render_boolean_control :include_hostfactory, 'Include hostfactory?'
    end
  end
end
