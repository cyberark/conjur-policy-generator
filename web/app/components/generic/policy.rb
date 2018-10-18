module Policy
  def inc variable
    lambda {
      store.increase variable
      render!
    }
  end

  def dec variable
    lambda {
      store.decrease variable
      render!
    }
  end

  def toggle variable
    lambda { |e|
      store.set variable, e.target.checked
      render!
    }
  end

  def update variable
    lambda { |e|
      store.set variable, e.target.value
      render!
    }
  end

  def generic_control description, extra_prepend=lambda{}, &block
    div.numeric_control.input_group do
      div.input_group_prepend do
        label.input_group_text do
          text description
        end
        extra_prepend.()
      end
      yield if block_given?
    end
  end

  def render_text_control variable, description
    generic_control description do
      input.form_control type: 'text',
                         value: store.value(variable),
                         oninput: update(variable),
                         style: {'border-color': 'white', 'border-radius': '4px',}
    end
  end

  def render_numeric_control variable, description
    generic_control description, lambda {
      button.btn.btn_outline_secondary style: {background: '#35C5C1', 'color': 'white', 'font-weight': '800', 'border-color': '#35C5C1', 'border-radius': '50%', 'height': '40px',
      'width': '40px',},
                                       onclick: dec(variable) do
        text '-'
      end
    } do
      input.form_control.text_center type: 'text',
                                     value: store.value(variable),
                                     disabled: true,
                                     style: {background: 'white', 'border-color': 'white', 'border-radius': '4px'}
      div.input_group_append do
        button.btn.btn_outline_secondary style: {background: '#35C5C1', 'color': 'white', 'font-weight': '800', 'border-color': '#35C5C1', 'border-radius': '50%', 'height': '40px',
      'width': '40px'},
                                         onclick: inc(variable) do
          text '+'
        end
      end
    end
  end

  def render_boolean_control variable, description
    generic_control description, lambda {
      div.input_group_text do
        input type: 'checkbox',
              value: store.value(variable),
              onchange: toggle(variable),
              aria: {label: description}
      end
    }
  end

  def render_download_button
    data_encoded = ::Base64.encode64 store.policy_text
    uri = "data:application/yaml;base64,#{data_encoded}"
    div.input_group style: {padding: '30px 10px 10px 0px',
                            'margin-top': '-0.5rem',
                            } do
      a href: uri,
        target: '_blank',
        download: 'policy.yml',
        style: {border: '1px solid #4D84B8',
                'border-radius': '5px',
                'background': '#4D84B8',} do
        span.input_group_btn do
          button.btn.btn_default.btn_prim 'Download Policy'
        end
      end
    end
  end

  def render_policy
    div.policy_config_display.box do
      h4 do
        text props[:header]
      end if props[:header]
      div style: {'font-family': 'monospace',
                  'white-space': 'pre',
                  'background': '#0E2234',
                  'color': 'white',
                  padding: '30px',
                  'padding-bottom': '2.5rem',
                 } do
        text store.policy_text
      end
    end
  end

  def render_footer &block
    div.policy_config_list.box do
      yield
    end
    # div.container style: {visibility: 'hidden'} do
    #   yield
    # end
  end
end