require_relative 'systems/graphics_ncurses'
require_relative 'systems/physics'

# Initialization
EntityHandler::System.components_load('components/')
EntityHandler::System.entities_load('entities/')

graphics_system = EntityHandler::GraphicsNcurses.new()
graphics_system = EntityHandler::Physics.new()

# Create a new entity
entity_id = EntityHandler::System.entity_create('object_ncurses')
EntityHandler::System.callback_trigger({'type_id'=>'scene_update', 'entity_id'=>entity_id, 'string'=>'Hello World'})
EntityHandler::System.callback_trigger({'type_id'=>'velocity_apply', 'entity_id'=>entity_id, 'x'=>5, 'y'=>1, 'z'=>0})

# Main Loop
time = Time.now().to_f()
while true
  prev_time = time
  time = Time.now().to_f()
  EntityHandler::System.callback_trigger({'type_id'=>'time_passed', 'time_delta'=>time-prev_time})
end

# Shutdown the program
EntityHandler::System.callback_trigger({'type_id'=>'shutdown'})
