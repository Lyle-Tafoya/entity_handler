require "entity_handler/version"

# The EntityHandler module will contain all classes needed to begin developing simulation software
module EntityHandler
  require 'json'

  # A system is a generic class which defines a standardized method of communication.
  # Systems communicate by broadcasting and listening for messages consisting of key-value pairs. 
  #
  # @author Lyle Tafoya
  # @abstract
  class System

    # Map where keys are message type_ids and values are arrays of System callback methods
    @@callback_registry = {}

    # Map where keys are entity names and values are names of the components of which they are comprised.
    # Used as templates for creating new entities
    @@entities = {}

    # Map where keys are component identifiers and values are Maps representing the component data. 
    # Used as templates for creating new components
    @@components = {}

    # Register a callback method to be run when a particular type of message is broadcasted
    # @param type_id [Integer]
    # @param callback [Method]
    def self.register_callback(type_id, callback)
      @@callback_registry[type_id] = [] unless @@callback_registry.key?(type_id)
      @@callback_registry[type_id].push(callback)
    end

    # Run all callback methods registered for the message type_id
    # @param message [Hash]
    def self.broadcast_message(message)
      @@callback_registry[message['type_id']].each {|callback| callback.call(message) }
    end

    # Listen for incoming messages over the network on a particular port
    # @param port [Integer]
    def self.listen(port)
    end

    # Scan a directory and load all components into memory
    # @param directory_path [String]
    def self.load_components(directory_path)
      Dir.foreach(directory_path) do |filename|
        next unless filename.include?('.json')
        component_name = filename.split(/\.json$/)
        @@components[component_name] = JSON.parse(File.read(directory_path + filename))
      end
    end

    # Clear the components map
    def self.unload_components()
      @@components = {}
    end

    # Remove a component from the components map
    # @param component [String]
    def self.unload_component(component)
      @@components.delete(component) if @@components.key?(component)
    end

    # Scan a directory and load all entities into memory
    # @param directory_path [String]
    def self.load_entities(directory_path)
      Dir.foreach(directory_path) do |filename|
        next unless filename.include?('.json')
        entity_name = filename.split(/\.json$/)
        @@entities[entity_name] = JSON.parse(File.read(directory_path + filename))
      end
    end

    # Clear the entities map
    def self.unload_entities()
      @@entities = {}
    end

    # Remove an entity from the entity map
    # @param entity [String]
    def self.unload_entity(entity)
      @@entities.delete(entity) if @@entities.key?(entity)
    end

  end

end
