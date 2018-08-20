class NavBar
  include Inesita::Component

  def render
    nav.navbar.navbar_expand_lg.navbar_light.bg_light do
      span.navbar_brand do
        text 'Conjur Policy Generator'
      end
      div.collapse.navbar_collapse do
        ul.nav.navbar_nav.mr_auto do
          li.nav_item class: class_names(active: router.current_url?(:home)) do
            a.nav_link href: router.url_for(:home) do
              text 'Home'
            end
          end
          li.nav_item class: class_names(active: router.current_url?(:about)) do
            a.nav_link href: router.url_for(:about) do
              text 'About'
            end
          end
        end
      end
    end
  end
end
