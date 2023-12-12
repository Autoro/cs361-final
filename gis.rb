#!/usr/bin/env ruby

class Track
  def initialize(segments, name = nil)
    @segments = segments
    @name = name
  end

  def get_json()
    json = '{'
    json += '"type": "Feature", '

    if @name != nil
      json += '"properties": {'
      json += '"title": "' + @name + '"'
      json += '},'
    end

    json += '"geometry": {'
    json += '"type": "MultiLineString",'
    json +='"coordinates": ['

    @segments.each_with_index do |s, index|
      if index > 0
        json += ","
      end

      json += '['

      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end

        tsj += '['
        tsj += "#{c.lon},#{c.lat}"

        if c.ele != nil
          tsj += ",#{c.ele}"
        end

        tsj += ']'
      end

      json +=tsj
      json +=']'
    end

    json + ']}}'
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele = nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele = nil, name = nil, type = nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_json()
    json = '{"type": "Feature",'

    json += '"geometry": {"type": "Point","coordinates": '
    json += "[#{@lon},#{@lat}"

    if ele != nil
      json += ",#{@ele}"
    end

    json += ']},'

    if name != nil or type != nil
      json += '"properties": {'

      if name != nil
        json += '"title": "' + @name + '"'
      end

      if type != nil
        if name != nil
          json += ','
        end

        json += '"icon": "' + @type + '"'
      end

      json += '}'
    end

    json += "}"

    return json
  end
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(f)
    @features.append(t)
  end

  def to_geojson()
    json = '{"type": "FeatureCollection","features": ['

    @features.each_with_index do |f, i|
      if i != 0
        json +=","
      end

      json += f.get_json
    end

    json + "]}"
  end
end

def main()
  homeWaypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  storeWaypoint = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  firstTrackStart = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46)
  ]

  firstTrackEnd = [
    Point.new(-121, 45),
    Point.new(-121, 46)
  ]

  secondTrackStart = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5)
  ]

  firstTrack = Track.new([ TrackSegment.new(firstTrackStart), TrackSegment.new(firstTrackEnd) ], "track 1")
  secondTrack = Track.new([ TrackSegment.new(secondTrackStart) ], "track 2")

  world = World.new("My Data", [ homeWaypoint, storeWaypoint, firstTrack, secondTrack ])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end
