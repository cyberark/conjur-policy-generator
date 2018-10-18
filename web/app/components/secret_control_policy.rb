class SecretControlPolicy
  include Inesita::Component
  include Policy

  def render
    div.wrapper do
      render_footer do
        div.control_wrapper do
          render_text_control :application_name, 'App Name:'
          render_numeric_control :secret_groups, 'Number of Secret Groups:'
          render_numeric_control :secrets_per_group, 'Number of Secrets per Group:'
          render_boolean_control :include_hostfactory, 'Include HostFactory?'
        end
        render_download_button
      end
      render_policy
    end
  end
end