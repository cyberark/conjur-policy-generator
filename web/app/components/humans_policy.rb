class HumansPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    div.footer.container style: {position: 'fixed',
                                 bottom: '0px',
                                 left: '0px',
                                 right: '0px',
                                 padding: '1rem'} do
      render_numeric_control :users, 'Number of users:'
      render_numeric_control :groups, 'Number of groups:'
      render_numeric_control :users_per_group, 'Users per group:'
    end
  end
end
