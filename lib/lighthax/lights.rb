require 'lighthax/payload'

class Lights
  attr_accessor :serial_numbers
  attr_accessor :name_to_serial_number
  attr_accessor :serial_number_to_name
  attr_accessor :locations

  def initialize(rwhttp)
    @rwhttp = rwhttp
    @fixtures = @rwhttp.get("rApi/fixture")
    @raw_locations = @rwhttp.get("rApi/location")
    parse_fixtures
    parse_locations
  end

  def lights
    @lights
  end

  def fixtures
    @fixtures
  end

  def light(serial)
    @lights[serial]
  end

  def locations
    @flat_locations
  end

  def list_locations
    out = {}
    @flat_locations.each do |k, v|
      out[k] = v["name"]
    end
    out
  end

  def location_by_id(id)
    @flat_locations[id]
  end

  def parse_fixtures
    @serial_numbers = []
    @serial_number_to_name = {}
    @name_to_serial_number = {}
    @lights = {}
    @fixtures.each do |f|
      sn = f["serialNum"]
      name = f["name"]
      f["href"] = "/lights/#{sn}"
      @serial_numbers << sn
      @serial_number_to_name[sn] = name
      @name_to_serial_number[name] = sn
      @lights[sn] = f
    end
  end

  def parse_locations
    @flat_locations = {}
    # create kv of all locations
    @raw_locations.each do |loc|
      id = loc["id"]
      @flat_locations[id] = loc
    end
    # denormalize all nested light fixtures onto each location
    @flat_locations.each do |id,loc|
      serials = []
      denormalize_serials(serials, loc)
      loc["serials"] = serials
      loc.delete("childFixture")
      loc.delete("childLocation")
    end
  end

  def denormalize_serials(dst, loc)
    children = loc["childFixture"]
    if children
      children.each do |c|
        dst << c[9..-1]
      end
    else
    end
    childpaths = loc["childLocation"]
    if childpaths
      ids = childpaths.map{|p|p[10..-1].to_i}
      ids.each do |id|
        childloc = @flat_locations[id]
        denormalize_serials(dst, childloc)
      end
    end
  end

  def set_light_brightness(serial, level)
  end

  def set_location_brightness(id, level)
  end

  def blink_location_on(id)
  end

  def blink_location_off(id)
  end

  def blink_on(serials)
    payload = Lighthax::PayloadGenerator.blink(serials, true).to_json + "====="
    @rwhttp.post("cgi-bin/model.cgi", payload)
  end

  def blink_off(serials)
    payload = Lighthax::PayloadGenerator.blink(serials, false).to_json + "====="
    @rwhttp.post("cgi-bin/model.cgi", payload)
  end
end
