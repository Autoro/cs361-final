#!/usr/bin/env ruby

class Track
  attr_accessor :segments, :title

  def initialize(segments, title = nil)
    @segments = segments
    @title = title
  end

  def get_json()
    json = '{'
    json += '"type": "Feature", '

    if self.title != nil
      json += '"properties": {'
      json += '"title": "' + self.title + '"'
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
  attr_reader :longitude, :latitude, :elevation

  def initialize(longitude, latitude, elevation = nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end

  def get_json
    json = '['
    json += "#{ self.longitude },#{ self.latitude }"

    if self.elevation != nil
      json += ",#{ self.elevation }"
    end

    json += ']'
  end
end

class Waypoint
  attr_reader :point, :title, :icon

  def initialize(point, title = nil, icon = nil)
    @point = point
    @title = title
    @icon = icon
  end

  def get_json()
    json = '{"type": "Feature",'

    json += '"geometry": {"type": "Point","coordinates": '
    json += self.point.get_json
    json += '},'

    if self.title != nil or self.icon != nil
      json += '"properties": {'

      if self.title != nil
        json += '"title": "' + self.title + '"'
      end

      if self.icon != nil
        if self.title != nil
          json += ','
        end

        json += '"icon": "' + self.icon + '"'
      end

      json += '}'
    end

    json += "}"

    return json
  end
end

class World
  attr_accessor :name, :features
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(f)
    self.features.append(t)
  end

  def to_geojson()
    json = '{"type": "FeatureCollection","features": ['

    self.features.each_with_index do |feature, i|
      if i != 0
        json +=","
      end

      json += feature.get_json
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
