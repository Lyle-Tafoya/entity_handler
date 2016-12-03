require_relative 'systems/graphics_opengl'
require_relative 'systems/physics'

# Initialization
EntityHandler::System.components_load('components/')
EntityHandler::System.entities_load('entities/')

graphics_system = EntityHandler::GraphicsOpenGL.new(width:640, height:480, title:'Hello World')
graphics_system.models_load('assets/models/')

graphics_system = EntityHandler::Physics.new()

# Create a new entity
entity_id = EntityHandler::System.entity_create('object_3d')
EntityHandler::System.callback_trigger({'type_id'=>'scene_update', 'entity_id'=>entity_id, 'model_name'=>'hello_world'})
EntityHandler::System.callback_trigger({'type_id'=>'torque_apply', 'entity_id'=>entity_id, 'x'=>50, 'y'=>50, 'z'=>0})
EntityHandler::System.callback_trigger({'type_id'=>'velocity_apply', 'entity_id'=>entity_id, 'x'=>0, 'y'=>0, 'z'=>-1})

# Main Loop
time = Time.now().to_f()
while true
  prev_time = time
  time = Time.now().to_f()
  EntityHandler::System.callback_trigger({'type_id'=>'time_passed', 'time_delta'=>time-prev_time})
end

# Shutdown the program
EntityHandler::System.callback_trigger({'type_id'=>'shutdown'})
