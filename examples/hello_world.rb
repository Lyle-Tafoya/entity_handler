require_relative 'systems/graphics_ncurses'

begin
  graphics_system = EntityHandler::GraphicsNcurses.new()
  sleep(5)
ensure
  graphics_system.shutdown()
end
