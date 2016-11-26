require "entity_handler/version"
require_relative "id"

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
    @@callback_registry = Hash.new()

    # Map where keys are component names and values are arrays of System objects
    @@component_registry = Hash.new()

    # Map where keys are entity names and values are names of the components of which they are comprised.
    # Used as templates for creating new entities
    @@entities = Hash.new()

    # A class which generates ids
    @@entity_id_generator = Id.new()

    # Map where keys are component identifiers and values are Maps representing the component data. 
    # Used as templates for creating new components
    @@components = Hash.new()

    # Register a callback method to be run when a particular type of message is broadcasted
    # @param type_id [Integer]
    # @param callback [Method]
    def self.callback_register(type_id, callback)
      @@callback_registry[type_id] = [] unless @@callback_registry.key?(type_id)
      @@callback_registry[type_id].push(callback)
    end

    # Run all callback methods registered for the message type_id
    # @param message [Hash]
    def self.callback_trigger(message)
      @@callback_registry[message['type_id']].each do |callback|
        callback.call(message)
      end
    end

    # Listen for incoming messages over the network on a particular port
    # @param port [Integer]
    def self.listen(port)
    end

    # Scan a directory and load all components into memory
    # @param directory_path [String]
    def self.components_load(directory_path)
      Dir.foreach(directory_path) do |file_name|
        next unless file_name.include?('.json')
        System.component_load(directory_path + file_name)
      end
    end

    # Clear the components map
    def self.components_unload()
      @@components = {}
    end

    # Add a component to the components map
    # @param file_path [String]
    def self.component_load(file_path)
      component_name = file_path.split(/\.json/).first().split('/').last()
      @@components[component_name] = JSON.parse(File.read(file_path))
    end

    # Remove a component from the components map
    # @param component_name [String]
    def self.component_unload(component_name)
      if @@components.key?(component_name)
        @@components.delete(component_name) 
      end
    end

    # Create a new component
    # @param component_name [String]
    # @param entity_id [Integer]
    def self.component_create(component_name, entity_id)
      new_component = @@components[component_name]
      new_component['entity_id'] = entity_id
      @@component_registry[component_name].each do |system|
        system.component_add(component_name, new_component)
      end
    end

    # Remove a component from all systems
    # @param component_name [String]
    # @param entity_id [Integer]
    def self.component_delete(component_name, entity_id)
      @@component_registry[component_name].each do |system|
        system.component_remove(component_name, entity_id)
      end
    end

    # Scan a directory and load all entities into memory
    # @param directory_path [String]
    def self.entities_load(directory_path)
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

    # Create a new entity
    # @param entity_name [String]
    def self.create_entity(entity_name)
      entity_id = @@entity_id_generator.generate()
      @@entities[entity_name]['components'].each do |component_name|
        System.component_create(component_name, entity_id)
      end
    end
    
    # Remove an entity from all systems
    # @param entity_id [Integer]
    def self.entity_delete(entity_id)
      System.callback_trigger({
        'type_id'=>'delete_entity',
        'entity_id'=>entity_id
      })
      @@entity_id_generator.delete(entity_id)
    end

    # Hash where keys are entity_ids and values are component maps
    @entities = Hash.new()

    # Create a new system
    def initialize()
      System.callback_register('entity_delete', self.method(:entity_delete))
      System.callback_register('component_remove', self.method(:component_remove))
    end

    def components_register(valid_components)
      return unless valid_components && valid_components.size() > 0
      valid_components.each do |component_name|
        unless @@component_registry.key?(component_name)
          @@component_registry[component_name] = []
        end
        @@component_registry[component_name].push(self)
      end
    end

    # Delete entity and all it's components
    def entity_delete(message)
      entity_id = message['entity_id']
      if @entities.key?(entity_id)
        @entities.delete(entity_id)
      end
    end

    # Add a component to an entity
    # @param component_name [String]
    # @param component [Map]
    def component_add(component_name, component)
      entity_id = component['entity_id']
      unless @entities.key?(entity_id)
        @entities[entity_id] = {}
      end
      @entities[entity_id][component_name] = component
    end

    # Remove a component from an entity
    # @param message [Map]
    def component_remove(message)
      @entities[message['entity_id']].delete(message['component_name'])
    end

  end

end
