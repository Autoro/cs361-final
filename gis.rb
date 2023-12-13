#!/usr/bin/env ruby

require 'json'

class Track
  attr_accessor :segments, :properties

  def initialize(segments, properties = {})
    @segments = segments
    @properties = properties
  end

  def to_json(*args)
    result = {
      type: "Feature",
      geometry: {
        type: "MultiLineString",
        coordinates: []
      }
    }

    for segment in self.segments
      result[:geometry][:coordinates] << segment
    end

    if !self.properties.empty?
      result[:properties] = self.properties
    end

    result.to_json(*args)
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def to_json(*args)
    result = []

    for coordinate in coordinates
      result << coordinate
    end

    result.to_json(*args)
  end
end

class Point
  attr_reader :longitude, :latitude, :elevation

  def initialize(longitude, latitude, elevation = nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end

  def to_json(*args)
    result = [ self.longitude, self.latitude ]
    result << self.elevation unless self.elevation == nil

    result.to_json(*args)
  end
end

class Waypoint
  attr_reader :point, :properties

  def initialize(point, properties = {})
    @point = point
    @properties = properties
  end

  def to_json(*args)
    result = {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: self.point
      }
    }

    if !self.properties.empty?
      result[:properties] = self.properties
    end

    result.to_json(*args)
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

  def to_json(*args)
    result = {
      type: "FeatureCollection",
      features: []
    }

    for feature in self.features
      result[:features] << feature
    end

    result.to_json(*args)
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

  puts JSON.generate(world)
end

if File.identical?(__FILE__, $0)
  main()
end
