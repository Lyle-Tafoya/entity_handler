require_relative 'systems/graphics_ncurses'

EntityHandler::System.components_load('components/')
EntityHandler::System.entities_load('entities/')
graphics_system = EntityHandler::GraphicsNcurses.new()
sleep(2)
EntityHandler::System.callback_trigger({'type_id'=>'shutdown'})
