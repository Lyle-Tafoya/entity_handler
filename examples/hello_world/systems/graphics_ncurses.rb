# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class GraphicsNcurses < System

    @screen = nil

    def initialize()
      @screen = Ncurses.initscr()
      Ncurses.noecho()
      Ncurses.keypad(@screen, true)
      Ncurses.curs_set(0)
      Ncurses.refresh()

      self.components_register(['location'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('time_passed', self.method(:update))
    end

    def update(message)
      @entities.each do |entity_id, entity_data|
        Ncurses.mvaddstr(entity_data['location']['values']['y'], entity_data['location']['values']['x'], 'Hello World')
      end
      Ncurses.update()
    end

    def shutdown(message)
      Ncurses.endwin()
    end

  end

end
