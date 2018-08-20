class Router
  include Inesita::Router

  def routes
    route '/', to: Home
    route '/about', to: About
  end
end
