# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class GraphicsNcurses < System

    @screen = nil

    def initialize()
      self.components_register(['location', 'sprite_ncurses'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('sprite_update', self.method(:sprite_update))
      System.callback_register('time_passed', self.method(:update))

      @screen = Ncurses.initscr()
      Ncurses.curs_set(0)
    end

    def sprite_update(message)
      @entities[message['entity_id']]['sprite_ncurses']['string'] = message['string']
    end

    def update(message)
      @entities.each do |entity_id, components|
        location = components['location']
        Ncurses.mvwaddstr(@screen, location['y'].to_i(), location['x'].to_i(), components['sprite_ncurses']['string'])
      end
      Ncurses.wrefresh(@screen)
      @entities.each do |entity_id, components|
        location = components['location']
        Ncurses.mvwaddstr(@screen, location['y'].to_i(), location['x'].to_i(), ' '*components['sprite_ncurses']['string'].size())
      end
    end

    def shutdown(message)
      Ncurses.endwin()
    end

  end

end
