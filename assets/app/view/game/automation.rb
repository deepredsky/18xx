# frozen_string_literal: true

require_tree 'engine'
module View
  module Game
    class Automation < Form
      include Actionable
      needs :mode, default: nil, store: true

      def render_selected
        params = @mode.parameters(@game)
        params.map do |key, value|
          case value
          when Array
            values = value.map do |entity|
              h(:option, { attrs: { value: entity.name } }, entity.full_name)
            end
            render_input(key, id: key, el: 'select', on: { input2: :limit_range }, children: values)
          end
        end
      end

      def render_content
        message = <<~MESSAGE
          <p>Programmed actions allows you to preprogram your moves ahead of time. on asyncronous games this can.</p>
          <p>On asynchronous games this can shorten a game considerably.</p>
          <p>Please note, these are not to be considered secret from other players.</p>
          <p>This is presently under development, more actions will be available soon.</p>
        MESSAGE

        h(:div, '')

        action_options = [mode_input(nil, 'None')]

        Engine::Automation.available(@game).each do |x|
          action_options << mode_input(x, x.description)
          action_options += render_selected if x == @mode
        end

        props = {
          props: { innerHTML: message },
          style: { margin: '2rem 1rem' },
        }

        children = [h(:div, props),
                    h(:div, action_options),
                    render_button('Save') { submit }]

        h(:div, children)
      end

      def submit
        # Map the parameters back
        puts "Submit! #{params}"
        fparams = @mode.parameters(@game).map do |k, value|
          selected = params[k]
          case value
          when Array
            selected = value.find { |entity| entity.name == selected }
          end
          [k, selected]
        end.to_h
        fparams[:id] = @game.actions.size
        puts "F parameters #{fparams}"
        obj = @mode.new(fparams)
        puts obj
      end

      def mode_input(mode, text)
        click_handler = lambda do
          store(:mode, mode)
        end

        render_input(
          text,
          id: text,
          type: 'radio',
          attrs: { name: 'mode_options', checked: @mode == mode },
          on: { click: click_handler },
          label_first: false,
          container_style: { display: 'block' },
        )
      end
    end
  end
end