class About
  include Inesita::Component

  def render
    div.jumbotron.text_center.bg_light.about_wrapper do
      p do
        text 'This is a proof of concept web UI for the Conjur policy generator.'
        br
        text 'You can find the source code, report a bug, or open an issue '
        a href: 'https://github.com/cyberark/conjur-policy-generator' do
          text 'on GitHub'
        end
        text '.'
      end
    end
  end
end
