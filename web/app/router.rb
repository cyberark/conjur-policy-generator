class Router
  include Inesita::Router

  def go_home
    lambda { go_to '/conjur-policy-generator/' }
  end

  def routes
    route '/conjur-policy-generator/about', to: About
    route ('/conjur-policy-generator/?'), to: Home
    route '/', to: Home, on_enter: go_home
  end
end
