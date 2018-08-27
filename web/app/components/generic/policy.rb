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
    div.numeric_control.input_group.mb_2 do
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
                         style: {'max-width': '20ex'}
    end
  end

  def render_numeric_control variable, description
    generic_control description, lambda {
      button.btn.btn_outline_secondary style: {background: 'white'},
                                       onclick: dec(variable) do
        text '-'
      end
    } do
      input.form_control.text_center type: 'text',
                                     value: store.value(variable),
                                     disabled: true,
                                     style: {'max-width': '3em'}
      div.input_group_append do
        button.btn.btn_outline_secondary style: {background: 'white'},
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
    div.input_group style: {padding: '1rem',
                            'margin-top': '-0.5rem',
                            background: 'white'} do
      a href: uri,
        target: '_blank',
        download: 'policy.yml',
        style: {background: 'white'} do
        span.input_group_btn do
          button.btn.btn_default.btn_secondary 'Download Policy YAML'
        end
      end
    end
  end

  def render_policy
    div.wrapper_policy do
      h4 do
        text props[:header]
      end if props[:header]
      div style: {'font-family': 'monospace',
                  'color': 'white',
                  'white-space': 'pre',
                  padding: '8px',
                  'padding-bottom': '2.5rem',
                  'border-bottom': '3px dashed white',
                 } do
        text store.policy_text
      end
    end
    render_download_button
  end

  def render_footer &block
    div.policy_addition_sidebar do
      yield
    end
  end
end
