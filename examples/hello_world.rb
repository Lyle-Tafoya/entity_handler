require_relative 'systems/graphics_ncurses'

begin
  graphics_system = EntityHandler::GraphicsNcurses.new()
  sleep(2)
ensure
  EntityHandler::System.broadcast_message({'type_id'=>'shutdown'})
end
