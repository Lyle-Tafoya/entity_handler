require "entity_handler/version"

# The EntityHandler module will contain all classes needed to begin developing simulation software
module EntityHandler
  require 'json'
  require 'set'

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

    # Map where keys are component identifiers and values are Maps representing the component data. 
    # Used as templates for creating new components
    @@component_templates = Hash.new()

    # Number of entities created since application start
    @@entity_count = 0

    # Map where keys are entity ids and values are arrays of System objects
    @@entity_registry = Hash.new()

    # Map where keys are entity names and values are names of the components of which they are comprised.
    # Used as templates for creating new entities
    @@entity_templates = Hash.new()

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

    # Create a new component
    # @param component_name [String]
    # @param entity_id [Integer]
    def self.component_create(component_name, entity_id)
      new_component = @@component_templates[component_name]
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

    # Add a component to the component_templates map
    # @param file_path [String]
    def self.component_load(file_path)
      component_name = file_path.split(/\.json/).first().split('/').last()
      @@component_templates[component_name] = JSON.parse(File.read(file_path))
    end

    # Remove a component from the component_templates map
    # @param component_name [String]
    def self.component_unload(component_name)
      if @@component_templates.key?(component_name)
        @@component_templates.delete(component_name) 
      end
    end

    # Scan a directory and load all components into memory
    # @param directory_path [String]
    def self.components_load(directory_path)
      Dir.foreach(directory_path) do |file_name|
        next unless file_name.include?('.json')
        System.component_load(directory_path + file_name)
      end
    end

    # Clear the component_templates map
    def self.components_unload()
      @@component_templates = {}
    end

    # Scan a directory and load all entities into memory
    # @param directory_path [String]
    def self.entities_load(directory_path)
      Dir.foreach(directory_path) do |file_name|
        next unless file_name.include?('.json')
        System.entity_load(directory_path + file_name)
      end
    end

    # Clear the entity_templates map
    def self.entities_unload()
      @@entity_templates = {}
    end

    # Create a new entity based on an entry in the entity_templates map
    # @param entity_name [String]
    # @return [Integer]
    def self.entity_create(entity_name)
      entity_id = @@entity_count
      @@entity_count += 1
      entity_systems = Set.new()
      @@entity_templates[entity_name]['components'].each do |component_name|
        @@component_registry[component_name].each do |system|
          entity_systems.add(system)
        end
        System.component_create(component_name, entity_id)
      end
      @@entity_registry[entity_id] = entity_systems.to_a()

      return entity_id
    end
    
    # Remove an entity from all systems
    # @param entity_id [Integer]
    def self.entity_delete(entity_id)
      @@entity_registry[entity_id].each do |system|
        system.entity_remove(entity_id)
      end
      @@entity_registry.delete(entity_id)
      @@entity_id_generator.delete(entity_id)
    end

    # Add an entity to the entity_templates map
    # @param file_path [String]
    def self.entity_load(file_path)
      entity_name = file_path.split(/\.json/).first().split('/').last()
      @@entity_templates[entity_name] = JSON.parse(File.read(file_path))
    end

    # Remove an entity from the entity_templates map
    # @param entity [String]
    def self.entity_unload(entity)
      @@entity_templates.delete(entity) if @@entity_templates.key?(entity)
    end

    # Listen for incoming messages over the network on a particular port
    # @param port [Integer]
    def self.listen(port)
    end

    # Hash where keys are entity_ids and values are component maps
    @entities = Hash.new()

    # Add a component to an entity
    # @param component_name [String]
    # @param component [Map]
    def component_add(component_name, component)
      entity_id = component['entity_id']
      @entities = {} unless @entities
      unless @entities.key?(entity_id)
        @entities[entity_id] = {}
      end
      @entities[entity_id][component_name] = component
    end

    # Remove a component from an entity
    # @param component_name [String]
    # @param entity_id [Integer]
    def component_remove(component_name, entity_id)
      @entities[entity_id].delete(component_name)
    end

    # Register an array of component names to this system
    # @param valid_components [Array]
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
    # @param entity_id [Integer]
    def entity_remove(entity_id)
      if @entities.key?(entity_id)
        @entities.delete(entity_id)
      end
    end

  end

end
