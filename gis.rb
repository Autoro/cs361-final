#!/usr/bin/env ruby

class Track
  attr_accessor :segments, :name

  def initialize(segments, name = nil)
    @segments = segments
    @name = name
  end

  def get_json()
    json = '{'
    json += '"type": "Feature", '

    if self.name != nil
      json += '"properties": {'
      json += '"title": "' + self.name + '"'
      json += '},'
    end

    json += '"geometry": {'
    json += '"type": "MultiLineString",'
    json +='"coordinates": ['

    self.segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end

      json += segment.get_json
    end

    json + ']}}'
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def get_json
    json = '['
      self.coordinates.each_with_index do |point, i|
        if i != 0
          json += ','
        end

        json += point.get_json
      end

      json += ']'
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele = nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

  def get_json
    json = '['
    json += "#{ self.lon },#{ self.lat }"

    if self.ele != nil
      json += ",#{ self.ele }"
    end

    json += ']'
  end
end

class Waypoint
  attr_reader :point, :name, :type

  def initialize(point, name = nil, type = nil)
    @point = point
    @name = name
    @type = type
  end

  def get_json()
    json = '{"type": "Feature",'

    json += '"geometry": {"type": "Point","coordinates": '
    json += self.point.get_json
    json += '},'

    if self.name != nil or self.type != nil
      json += '"properties": {'

      if self.name != nil
        json += '"title": "' + self.name + '"'
      end

      if self.type != nil
        if self.name != nil
          json += ','
        end

        json += '"icon": "' + self.type + '"'
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
  homeWaypoint = Waypoint.new(Point.new(-121.5, 45.5, 30), "home", "flag")
  storeWaypoint = Waypoint.new(Point.new(-121.5, 45.6), "store", "dot")

  firstTrack = Track.new([
    TrackSegment.new([
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46)
    ]),
    TrackSegment.new([
      Point.new(-121, 45),
      Point.new(-121, 46)
    ])
  ], "track 1")

  secondTrack = Track.new([
    TrackSegment.new([
      Point.new(-121, 45.5),
      Point.new(-122, 45.5)
    ])
  ], "track 2")

  world = World.new("My Data", [ homeWaypoint, storeWaypoint, firstTrack, secondTrack ])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end
