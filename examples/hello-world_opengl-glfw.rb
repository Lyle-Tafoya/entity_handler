require_relative 'systems/graphics_opengl'
require_relative 'systems/physics'

# Initialization
EntityHandler::System.components_load('components/')
EntityHandler::System.entities_load('entities/')

graphics_system = EntityHandler::GraphicsOpenGL.new()
graphics_system.models_load('assets/models/')

graphics_system = EntityHandler::Physics.new()

# Create a new entity
entity_a = EntityHandler::System.entity_create('object_opengl')
EntityHandler::System.callback_trigger({'type_id'=>'model_update', 'entity_id'=>entity_a, 'model_name'=>'hello_world'})
EntityHandler::System.callback_trigger({'type_id'=>'torque_apply', 'entity_id'=>entity_a, 'x'=>50, 'y'=>50, 'z'=>50})

# Main Loop
time = Time.now().to_f()
while true
  prev_time = time
  time = Time.now().to_f()
  EntityHandler::System.callback_trigger({'type_id'=>'time_passed', 'time_delta'=>time-prev_time})
end

# Shutdown the program
EntityHandler::System.callback_trigger({'type_id'=>'shutdown'})
