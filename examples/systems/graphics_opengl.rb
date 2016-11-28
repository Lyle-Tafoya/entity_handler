# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"

module EntityHandler
  require 'opengl'
  require 'glfw3'
  require 'assimp'

  class GraphicsOpenGL < System

    @window = nil
    @model_registry = Hash.new()

    def initialize(width:500, height:500, title:'EntityHandler::GraphicsOpenGL')
      self.components_register(['location', 'model_3d'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('time_passed', self.method(:update))
      System.callback_register('model_update', self.method(:model_update))

      Glfw.init()
      @window = Glfw::Window.new(width, height, title, nil, nil)
      @window.make_context_current()
      Glfw.swap_interval = 1
      window_size = @window.size()
      Gl.glViewport(0, 0, window_size.first(), window_size.last())
      Gl.glEnable(Gl::GL_DEPTH_TEST)
      Gl.glDepthFunc(Gl::GL_LESS)
    end

    def model_load(file_path)
      @model_registry = {} unless @model_registry
      importer = ASSIMP::Importer.new()
      model_name = file_path.split('/').last().split(/\.\w+$/).first()
      @model_registry[model_name] = importer.read_file(file_path)
    end

    def model_update(message)
      @entities[message['entity_id']]['model_3d']['model_data'] = @model_registry[message['model_name']]
    end

    def models_load(directory_path)
      Dir.foreach(directory_path) do |file_name|
        next unless file_name.include?('.dae')
        model_load(directory_path + file_name)
      end
    end

    def update(message)
      Gl.glLoadIdentity()
      Gl.glScalef(0.3, 0.3, 0.3)
      Gl.glClear(Gl::GL_COLOR_BUFFER_BIT | Gl::GL_DEPTH_BUFFER_BIT)
      Gl.glColor3f(1, 1, 1)
      @entities.each do |entity_id, components|
        Gl.glPushMatrix()
        location = components['location']
        Gl.glRotatef(location['pitch'], 1, 0, 0)
        Gl.glRotatef(location['yaw'], 0, 1, 0)
        Gl.glRotatef(location['roll'], 0, 0, 1)
        x = location['x']; y = location['y']; z = location['z']
        components['model_3d']['model_data']['meshes'].each do |mesh|
          Gl.glBegin(Gl::GL_TRIANGLES)
          mesh['vertices'].each_slice(3) do |triangle|
            triangle.each do |vertice|
              Gl.glVertex3f(vertice['x']+x, vertice['y']+y, vertice['z']+z)
            end
          end
          Gl.glEnd()
        end
        Gl.glPopMatrix()
      end

      @window.swap_buffers()
    end

    def shutdown(message)
      Glfw.terminate()
    end

  end

end
