class Home
  include Inesita::Component

  def render
    div.bg_light style: {'margin-bottom': '10rem'} do
      component Policy
    end
  end
end
