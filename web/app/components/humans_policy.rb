class HumansPolicy
  include Inesita::Component
  include Policy

  def render
    div.wrapper do
      render_footer do
        div.control_wrapper do
          render_numeric_control :users, 'Number of Users:'
          render_numeric_control :groups, 'Number of Groups:'
          render_numeric_control :users_per_group, 'Users per Group:'
        end
      end
      render_policy
    end
  end
end
