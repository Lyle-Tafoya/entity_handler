# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class Physics < System

    def initialize()
      self.components_register(['orientation', 'position', 'torque', 'velocity'])

      System.callback_register('position_update', self.method(:position_update))
      System.callback_register('torque_apply', self.method(:torque_apply))
      System.callback_register('time_passed', self.method(:update))
      System.callback_register('velocity_apply', self.method(:velocity_apply))
    end

    def orientation_update(message)
    end

    def position_update(message)
      position = @entities[message['entity_id']]['position']
      position['x'] = message['x']
      position['y'] = message['y']
      position['z'] = message['z']
    end

    def update(message)
      time_delta = message['time_delta']
      @entities.each do |entity_id, components|
        position = components['position']
        velocity = components['velocity']
        position['x'] += velocity['x'] * time_delta
        position['y'] += velocity['y'] * time_delta
        position['z'] += velocity['z'] * time_delta

        orientation = components['orientation']
        torque = components['torque']
        orientation['pitch'] += torque['pitch'] * time_delta
        orientation['roll'] += torque['roll'] * time_delta
        orientation['yaw'] += torque['yaw'] * time_delta
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
