class SecretsPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    div.footer.container style: {position: 'fixed',
                                 bottom: '0px',
                                 left: '0px',
                                 right: '0px',
                                 padding: '1rem'
                                } do
      render_numeric_control :secrets, 'Number of secrets:'
      render_numeric_control :annotations_per_secret, 'Annotations per secret:'
    end
  end
end
