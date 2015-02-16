$simport.r('iss2/parax', '1.0.0', 'An automatic Parallax mapping system')

module ISS2
  module Parax
    class SpritesetParallax
      attr_reader :ox
      attr_reader :oy
      attr_reader :viewport

      def initialize(viewport)
        @viewport = viewport
        @ox = 0
        @oy = 0
        @layers = []
        create_layers
      end

      def game_map
        $game_map
      end

      def create_layer(basename, z)
        bmp = begin
          Cache.parallax_map("#{basename}#{game_map.map_id}")
        rescue
          return
        end
        layer = Plane.new(@viewport)
        layer.z = z
        layer.bitmap = bmp
        @layers << layer
      end

      def create_layers
        create_layer('ground', 1)
        create_layer('par', 900)
      end

      def dispose_layers
        @layers.each(&:dispose)
        @layers.clear
      end

      def dispose
        dispose_layers
      end

      def update_layers
        @layers.each(&:update)
      end

      def update
        update_layers
      end

      def ox=(ox)
        @ox = ox
        @layers.each { |l| l.ox = @ox }
      end

      def oy=(oy)
        @oy = oy
        @layers.each { |l| l.oy = @oy }
      end

      def viewport=(viewport)
        @viewport = viewport
        @layers.each { |l| l.viewport = @viewport }
      end
    end
    module SpritesetMix
      def create_parax
        @parax = SpritesetParallax.new(@viewport1)
      end

      def dispose_parax
        @parax && @parax.dispose
      end

      def update_parax
        if @parax
          @parax.update
          @parax.ox = @tilemap.ox
          @parax.oy = @tilemap.oy
        end
      end
    end
  end
end

class Spriteset_Map
  include ISS2::Parax::SpritesetMix

  alias :iss2_parax_spm_create_all :create_all
  def create_all(*args, &block)
    iss2_parax_spm_create_all(*args, &block)
    create_parax
  end

  alias :iss2_parax_spm_dispose :dispose
  def dispose(*args, &block)
    iss2_parax_spm_dispose(*args, &block)
    dispose_parax
  end

  alias :iss2_parax_spm_update :update
  def update(*args, &block)
    iss2_parax_spm_update(*args, &block)
    update_parax
  end
end
