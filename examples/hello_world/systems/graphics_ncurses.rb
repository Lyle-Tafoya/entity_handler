# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class GraphicsNcurses < System

    @screen = nil

    def initialize()
      super()
      @screen = Ncurses.initscr()
      Ncurses.noecho()
      Ncurses.keypad(@screen, true)
      Ncurses.curs_set(0)
      Ncurses.mvaddstr(5, 5, 'Hello World')
      Ncurses.refresh()

      System.callback_register('shutdown', self.method(:shutdown))
      self.components_register(['location'])
    end

    def shutdown(message)
      Ncurses.endwin()
    end

  end

end
