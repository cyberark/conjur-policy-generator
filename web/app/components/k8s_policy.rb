class KubernetesPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    render_footer do
      render_text_control :app_name, 'App name:'
      render_text_control :app_namespace, 'App namespace:'
      render_text_control :authenticator_id, 'Authenticator ID:'
    end
  end
end
