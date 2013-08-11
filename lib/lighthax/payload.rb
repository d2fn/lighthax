module Lighthax
  class PayloadGenerator
    def self.blink(serials, enabled)
      {
        :set => {
          :name => "cluster",
          :type => "RmlEntity",
          :change => 0,
          :children => [
            {
              :name => "fixture",
              :type => "RmlEntityList",
              :change => 0,
              :children => serials.map{|s|blink_child(s, enabled)}
            }
          ]
        }
      }
    end

    def self.blink_child(serial, enabled)
      {
        :name => "fixture",
        :type => "RmlEntity",
        :change => 0,
        :children => [
          {
            :name => "serialNum",
            :type => "RmlAttribute",
            :value => serial,
            :change => 0
          },
          {
            :name => "blinkModeEnabled",
            :type => "RmlAttribute",
            :value => enabled.to_s,
            :change => 0
          }
        ]
      }
    end
  end
end
