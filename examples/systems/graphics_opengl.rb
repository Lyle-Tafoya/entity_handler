# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"

module EntityHandler
  require 'opengl'
  require 'glu'
  require 'glfw3'
  require 'assimp'

  class GraphicsOpenGL < System

    @window = nil
    @model_registry = Hash.new()

    def initialize(width:500, height:500, title:'EntityHandler::GraphicsOpenGL')
      self.components_register(['orientation', 'position', 'scene_3d'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('time_passed', self.method(:update))
      System.callback_register('scene_update', self.method(:scene_update))

      Glfw.init()
      @window = Glfw::Window.new(width, height, title, nil, nil)
      @window.make_context_current()
      window_size = @window.framebuffer_size()
      Glfw.swap_interval = 1
      Gl.glClearColor(0.0, 0.0, 0.0, 0.0)
      Gl.glEnable(Gl::GL_DEPTH_TEST)
      Gl.glDepthFunc(Gl::GL_LESS)
      window_resize(window_size.first(), window_size.last())
    end
 
    def window_resize(width, height)
      Gl.glViewport(0, 0, width, height)
      Gl.glMatrixMode(Gl::GL_PROJECTION)
      Gl.glLoadIdentity()
      Glu.gluPerspective(60.0, width/height, 1.0, 20.0)
      Gl.glMatrixMode(Gl::GL_MODELVIEW)
      Gl.glLoadIdentity()
      Glu.gluLookAt(0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
    end

    def model_load(file_path)
      @model_registry = {} unless @model_registry
      importer = ASSIMP::Importer.new()
      model_name = file_path.split('/').last().split(/\.\w+$/).first()
      @model_registry[model_name] = importer.read_file(file_path)
    end

    def scene_update(message)
      @entities[message['entity_id']]['scene_3d']['model_data'] = @model_registry[message['model_name']]
    end

    def models_load(directory_path)
      Dir.foreach(directory_path) do |file_name|
        next unless file_name.include?('.dae')
        model_load(directory_path + file_name)
      end
    end

    def update(message)
      Gl.glClear(Gl::GL_COLOR_BUFFER_BIT | Gl::GL_DEPTH_BUFFER_BIT)
      @entities.each do |entity_id, components|
        Gl.glPushMatrix()
        orientation = components['orientation']
        Gl.glRotatef(orientation['pitch'], 1, 0, 0)
        Gl.glRotatef(orientation['yaw'], 0, 1, 0)
        Gl.glRotatef(orientation['roll'], 0, 0, 1)
        position = components['position']
        x = position['x']; y = position['y']; z = position['z']
        components['scene_3d']['model_data']['meshes'].each do |mesh|
          Gl.glBegin(Gl::GL_TRIANGLES)
          mesh['vertices'].each do |vertice|
            srand(vertice.hash)
            shade = rand()
            Gl.glColor3f(shade, shade, shade)
            Gl.glVertex3f(vertice['x']+x, vertice['y']+y, vertice['z']+z)
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
