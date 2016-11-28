# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"
require "ncurses"

module EntityHandler

  class InputNcurses < System
    @screen

    def initialize()
      @screen = Ncurses.initscr()
      Ncurses.noecho()
      Ncurses.keypad(@screen, true)
      Ncurses.curs_set(0)
    end

    def update(message)
      Ncurses.getch()
    end

    def shutdown(message)
      Ncurses.endwin()
    end
  end

end
