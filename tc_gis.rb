require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase
  def setup
    @homeWaypoint = Waypoint.new(Point.new(-121.5, 45.5, 30), "home", "flag")
    @storeWaypoint = Waypoint.new(Point.new(-121.5, 45.6), "store", "dot")

    @firstTrack = Track.new([
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

    @secondTrack = Track.new([
      TrackSegment.new([
        Point.new(-121, 45.5),
        Point.new(-122, 45.5)
      ])
    ], "track 2")
  end

  def test_waypoint_complete
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(@homeWaypoint.get_json)

    assert_equal(result, expected)
  end

  def test_waypoint_no_elevation_or_name
    waypoint = Waypoint.new(Point.new(-121.5, 45.5), nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_json)

    assert_equal(result, expected)
  end

  def test_waypoint_no_eleveation_or_type
    waypoint = Waypoint.new(Point.new(-121.5, 45.5), "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_json)

    assert_equal(result, expected)
  end

  def test_track_two_points
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(@firstTrack.get_json)

    assert_equal(expected, result)
  end

  def test_track_one_point
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(@secondTrack.get_json)

    assert_equal(expected, result)
  end

  def test_world
    world = World.new("My Data", [ @homeWaypoint, @storeWaypoint, @firstTrack, @secondTrack ])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(world.to_geojson)

    assert_equal(expected, result)
  end
end
