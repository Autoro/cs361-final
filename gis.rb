#!/usr/bin/env ruby

require 'json'

class Track
  attr_accessor :segments, :properties

  def initialize(segments, properties = {})
    @segments = segments
    @properties = properties
  end

  def get_json()
    json = '{'
    json += '"type": "Feature", '
    json += '"geometry": {'
    json += '"type": "MultiLineString",'
    json +='"coordinates": ['

    self.segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end

      json += segment.get_json
    end

    json += ']}'

    if !self.properties.empty?
      json += ', "properties": ' + self.properties.to_json
    end

    json += '}'
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
  attr_reader :point, :properties

  def initialize(point, properties = {})
    @point = point
    @properties = properties
  end

  def get_json()
    json = '{'
    json += '"type": "Feature",'
    json += '"geometry": {'
    json += '"type": "Point", '
    json += '"coordinates": ' + self.point.get_json
    json += '}'

    if !self.properties.empty?
      json += ', "properties": ' + self.properties.to_json
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

  def add_feature(feature)
    self.features << feature
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
  homeWaypoint = Waypoint.new(Point.new(-121.5, 45.5, 30), { title: "home", icon: "flag" })
  storeWaypoint = Waypoint.new(Point.new(-121.5, 45.6), { title: "store", icon: "dot" })

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
    ],
    { title: "track 1" }
  )

  secondTrack = Track.new([
      TrackSegment.new([
        Point.new(-121, 45.5),
        Point.new(-122, 45.5)
      ])
    ],
    { title: "track 2" }
  )

  world = World.new("My Data", [ homeWaypoint, storeWaypoint, firstTrack, secondTrack ])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end
