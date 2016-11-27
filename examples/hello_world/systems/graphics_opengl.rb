# Created on 10/22/2016 by Lyle Tafoya
#
require "entity_handler"

module EntityHandler
  require 'opengl'
  require 'glfw3'

  class GraphicsOpenGL < System

    @window = nil

    def initialize(width:500, height:500, title:'Hello World')
      self.components_register(['location'])
      System.callback_register('shutdown', self.method(:shutdown))
      System.callback_register('time_passed', self.method(:update))

      Glfw.init()
      @window = Glfw::Window.new(width, height, title, nil, nil)
      @window.make_context_current()
      Glfw.swap_interval = 1
    end

    def update(message)

        Gl.glClear(Gl::GL_COLOR_BUFFER_BIT)
        window_size = @window.size()
        Gl.glViewport(0, 0, window_size.first(), window_size.last())
        @entities.each do |entity_id, components|
          Gl.glBegin(Gl::GL_QUADS)
            location = components['location']
            x = location['x']; y = location['y']; z = location['z']
            Gl.glColor3f(1.0, 1.0, 1.0)
            Gl.glVertex3f(x/100.0, y/100.0, 0.0)
            Gl.glVertex3f(x/100.0+0.1, y/100.0, 0.0)
            Gl.glVertex3f(x/100.0+0.1, y/100.0+0.1, 0.0)
            Gl.glVertex3f(x/100, y/100.0+0.1, 0.0)
          Gl.glEnd()
        end

      @window.swap_buffers()
    end

    def shutdown(message)
      Glfw.terminate()
    end

  end

end
