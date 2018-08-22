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

  def render_numeric_control variable, description
    div.numeric_control.input_group.mb_2 do
      div.input_group_prepend do
        label.input_group_text do
          text description
        end
        button.btn.btn_outline_secondary style: {background: 'white'},
                                         onclick: dec(variable) do
          text '-'
        end
      end
      input.form_control.text_center type: "text",
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

  def render_download_button
    data_encoded = `btoa(#{store.policy_text})`
    uri = "data:application/yaml;base64,#{data_encoded}"
    div.input_group style: {padding: '1rem',
                            'margin-top': '-0.5rem',
                            background: 'white'} do
      a href: uri,
        target: '_blank',
        download: 'policy.yml',
        style: {border: '1px solid #d4d4d4',
                'border-radius': '5px'} do
        span.input_group_btn do
          button.btn.btn_default 'Download Policy YAML'
        end
      end
    end
  end

  def render_policy
    h4 do
      text props[:header]
    end if props[:header]
    div style: {'font-family': 'monospace',
                'white-space': 'pre',
                padding: '8px',
                'padding-bottom': '2.5rem',
                'border-bottom': '3px dashed white',
                margin: '8px',
        } do
      text store.policy_text
    end
    render_download_button
  end
end
