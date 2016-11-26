require_relative 'systems/graphics_ncurses'

# Initialization
EntityHandler::System.components_load('components/')
EntityHandler::System.entities_load('entities/')
graphics_system = EntityHandler::GraphicsNcurses.new()

# Create a new entity
entity_id = EntityHandler::System.entity_create('object_2d')

# Trigger our update methods
EntityHandler::System.callback_trigger({'type_id'=>'time_passed'})

# Pause so we can read the script output 
sleep(2)

# Shutdown the program
EntityHandler::System.callback_trigger({'type_id'=>'shutdown'})
