class NavBar
  include Inesita::Component

  def change_generator_to new_generator
    lambda {
      store.change_generator new_generator
      render!
    }
  end

  def name_for generator
    store.supported_generators.dig(generator, :name)
  end

  def render_policy_dropdown
    form.form_inline do
      div.input_group.template_wrapper do
        span.input_group_prepend do
          span.input_group_text do
            text 'Policy Template:'
          end
        end
        div.dropdown do
          button
            .btn
            .btn_outline_secondary
            .dropdown_toggle type: 'button',
                             id: 'dropdownMenuButton',
                             data: {toggle: 'dropdown'},
                             aria: {
                               haspopup: 'true',
                               expanded: 'false'
                             } do
            a.dropdown_option name_for store.current_generator
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
    end
  end

  def render
    nav.navbar do
      div.navbar_banner do
        div.navbar_img do
          img src: '/static/cyberark_conjur_logo_horiz_dark.svg', class: 'cyber_logo', alt: 'CyberArk Conjur Logo'
        end
        ul.navbar_options do
          li.nav_item class: class_names(active: router.current_url?(:about)) do
            a.nav_link.nav_link_primary href: router.url_for(:about) do
              text 'About'
            end
          end
          li.nav_item class: class_names(active: router.current_url?(:home)) do
            a.nav_link.nav_link_primary href: router.url_for(:home) do
              text 'Policy Generator'
            end
          end
        end
      end

    end
    div.policy_banner do
      span.navbar_brand.policy_banner.policy_title do
        text 'Policy Generator'
      end
    end
    render_policy_dropdown
  end
end
