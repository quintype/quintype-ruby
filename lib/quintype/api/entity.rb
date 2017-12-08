class API
  class Entity
    class << self
      def all(params)
        API.entities(params)
      end

      def find(id)
        API.find_entity(id)
      end

      def sub_entity(entity_id, sub_entity_id)
        API.sub_entity(entity_id, sub_entity_id)
      end
    end
  end
end
