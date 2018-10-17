class KubernetesPolicy
  include Inesita::Component
  include Policy

  def render
    div.wrapper do
      render_footer do
        div.control_wrapper do
          render_text_control :app_name, 'App Name:'
          render_text_control :app_namespace, 'App Namespace:'
          render_text_control :authenticator_id, 'Authenticator ID:'
        end
      end
      render_policy
    end
  end
end
