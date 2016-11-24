require_relative 'systems/graphics_ncurses'

begin
  EntityHandler::System.load_components('components/')
  EntityHandler::System.load_entities('entities/')
  graphics_system = EntityHandler::GraphicsNcurses.new()
  sleep(2)
ensure
  EntityHandler::System.broadcast_message({'type_id'=>'shutdown'})
end
