# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class Physics < System

    @screen = nil

    def initialize()
      self.components_register(['location', 'torque', 'velocity'])

      System.callback_register('teleport', self.method(:teleport))
      System.callback_register('torque_apply', self.method(:torque_apply))
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
        torque = components['torque']
        velocity = components['velocity']

        location['x'] += velocity['x'] * time_delta
        location['y'] += velocity['y'] * time_delta
        location['z'] += velocity['z'] * time_delta
        location['pitch'] += torque['pitch'] * time_delta
        location['roll'] += torque['roll'] * time_delta
        location['yaw'] += torque['yaw'] * time_delta
      end
    end

    def velocity_apply(message)
      velocity = @entities[message['entity_id']]['velocity']
      velocity['x'] += message['x']
      velocity['y'] += message['y']
      velocity['z'] += message['z']
    end

    def torque_apply(message)
      torque = @entities[message['entity_id']]['torque']
      torque['pitch'] += message['x']
      torque['roll'] += message['y']
      torque['yaw'] += message['z']
    end

  end

end
