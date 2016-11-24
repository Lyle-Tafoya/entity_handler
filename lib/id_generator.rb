require "entity_handler/version"

module EntityHandler
  require 'set'
  # Handle unique id generation
  #
  # @author Lyle Tafoya
  class Id
    @available_ids = Set.new()
    @used_ids = Set.new()
    num_ids = 0

    # Generate a new id. If there are old unused ids, use one of them first
    def generate()
      if @available_ids.size() > 0
        new_id = @available_ids.first()
        @available_ids.delete(new_id)
      else
        new_id = @@num_ids
        @@num_ids += 1
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
