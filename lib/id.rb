require "entity_handler/version"

module EntityHandler
  require 'set'
  # Handle unique id generation
  #
  # @author Lyle Tafoya
  class Id

    # Unused ids ready to be assigned
    @available_ids = []

    # Ids currently in use
    @used_ids = Set.new()

    # Generate a new id. If there are old unused ids, use one of them first
    # @return [Integer]
    def generate()
      if @available_ids.size() > 0
        new_id = @available_ids.pop()
      else
        new_id = @used_ids.size()
      end
      return new_id
    end

    # Mark an id as available
    # @param id [Integer]
    def delete(id)
      @used_ids.delete(id)
      @available_ids.add(id)
    end
  end

end
