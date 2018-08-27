class NavBar
  include Inesita::Component

  def change_generator_to new_generator
    lambda {
      store.change_generator new_generator
    }
  end

  def name_for generator
    store.supported_generators.dig(generator, :name)
  end

  def render_policy_dropdown
    div.dropdown do
      button
        .btn
        .btn_default
        .dropdown_toggle type: 'button',
                         id: 'dropdownMenuButton',
                         data: {toggle: 'dropdown'},
                         aria: {
                           haspopup: 'true',
                           expanded: 'false'
                         } do
        text name_for store.current_generator
      end
      div.dropdown_menu aria_labeledby: 'dropdownMenuButton' do
        store.supported_generators.each { |name, data|
          a.dropdown_item href: '#', onclick: change_generator_to(name) do
            text data.dig(:name)
          end
        }
      end
    end 
  end

  def render
    nav.navbar.navbar_expand_lg.navbar_light do
      img src: '/static/conjur_4c_ko.svg', class: 'cyber_logo', alt: 'CyberArk Conjur Logo'
      div.collapse.navbar_collapse do
        ul.nav.navbar_nav.mr_auto do
          li.nav_item class: class_names(active: router.current_url?(:home)) do
            a.nav_text href: router.url_for(:home) do
              text 'Home'
            end
          end
          li.nav_item class: class_names(active: router.current_url?(:about)) do
            a.nav_text href: router.url_for(:about) do
              text 'About'
            end
          end
          li.nav_item class: class_names(active: router.current_url?(:about)) do
            div.policy_temp_wrapper do
              a.nav_text href: router.url_for(:about) do
                text 'Policy template:'
              end
              render_policy_dropdown
            end
          end
        end
      end
    end
    div.policy_banner do
      h2.policy_banner_text do
        text 'CyberArk Conjur Policy Generator'
      end
    end
  end

end
