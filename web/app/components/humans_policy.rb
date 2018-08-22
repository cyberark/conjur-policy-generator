class HumansPolicy
  include Inesita::Component
  include Policy

  def render
    render_policy
    render_footer do
      render_numeric_control :users, 'Number of users:'
      render_numeric_control :groups, 'Number of groups:'
      render_numeric_control :users_per_group, 'Users per group:'
    end
  end
end
