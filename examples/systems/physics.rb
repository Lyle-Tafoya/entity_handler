# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class Physics < System

    @screen = nil

    def initialize()
      @screen = Ncurses.initscr()
      Ncurses.curs_set(0)

      self.components_register(['location', 'mass', 'velocity'])
      System.callback_register('teleport', self.method(:teleport))
      System.callback_register('time_passed', self.method(:update))
      System.callback_register('velocity_apply', self.method(:velocity_apply))
    end

    def teleport(message)
      location = @entities[message['entity_id']]['location']
      location['x'] = message['x']
      location['y'] = message['y']
      location['z'] = message['z']
    end

    def update(message)
      time_delta = message['time_delta']
      @entities.each do |entity_id, components|
        location = components['location']
        velocity = components['velocity']
        location['x'] += velocity['x'] * time_delta
        location['y'] += velocity['y'] * time_delta
        location['z'] += velocity['z'] * time_delta
      end
    end

    def velocity_apply(message)
      entity = @entities[message['entity_id']]
      entity['velocity']['x'] += message['x']
      entity['velocity']['y'] += message['y']
      entity['velocity']['z'] += message['z']
    end

  end

end
