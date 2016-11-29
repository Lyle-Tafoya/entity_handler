# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class GraphicsNcurses < System

    @screen = nil

    def initialize()
      self.components_register(['position', 'scene_ncurses'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('scene_update', self.method(:scene_update))
      System.callback_register('time_passed', self.method(:update))

      @screen = Ncurses.initscr()
      Ncurses.curs_set(0)
    end

    def scene_update(message)
      @entities[message['entity_id']]['scene_ncurses']['string'] = message['string']
    end

    def update(message)
      @entities.each do |entity_id, components|
        position = components['position']
        Ncurses.mvwaddstr(@screen, position['y'].to_i(), position['x'].to_i(), components['scene_ncurses']['string'])
      end
      Ncurses.wrefresh(@screen)
      @entities.each do |entity_id, components|
        position = components['position']
        Ncurses.mvwaddstr(@screen, position['y'].to_i(), position['x'].to_i(), ' '*components['scene_ncurses']['string'].size())
      end
    end

    def shutdown(message)
      Ncurses.endwin()
    end

  end

end
