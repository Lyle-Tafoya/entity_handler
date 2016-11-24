


# Overview -
#
# The Engine is comprised of systems. Each system is comprised of entities. Each entity is comprised of components.
# A Component is represented by key value pairs. This implementation will use maps to work with the data in memory.
# An Entity are represented by an id key value pair inside one or more Component maps. The Entity id can be passed between systems.
# Systems are classes capable of sending and receiving messages. They manage components.

require "entity_handler/version"

module EntityHandler

  # @author Lyle Tafoya
  class System
    @callbacks = {}
    @entities = {}
    @entity_types = {}

    def initialize()
    end


    def recieve_message(message)
      message_type = message['type_id']
      return unless @callbacks.key?(message_type)
      @callbacks[message_type].call()
    end

    def update(delta)
    end

    # Static members
    @@registry = {}

    @@update_queue = []
    def self.update_systems(delta)
      @@update_queue.each do |system|
        system.update(delta)
      end
    end

  end

end
