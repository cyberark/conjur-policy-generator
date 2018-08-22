class Router
  include Inesita::Router

  def routes
    route '/conjur-policy-generator/about', to: About
    route '/conjur-policy-generator/?', to: Home
    route '/', to: Home, on_enter: lambda { go_to '/conjur-policy-generator/' }
  end
end
