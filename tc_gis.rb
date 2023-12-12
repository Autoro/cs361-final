require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase
  def test_waypoints
    waypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(waypoint.get_waypoint_json)

    assert_equal(result, expected)

    waypoint = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_waypoint_json)

    assert_equal(result, expected)

    waypoint = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(waypoint.get_waypoint_json)

    assert_equal(result, expected)
  end

  def test_tracks
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

    firstTrack = Track.new([firstTrackStart, firstTrackEnd], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(firstTrack.get_track_json)

    assert_equal(expected, result)

    secondTrack = Track.new([secondTrackStart], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(secondTrack.get_track_json)

    assert_equal(expected, result)
  end

  def test_world
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

    firstTrack = Track.new([ firstTrackStart, firstTrackEnd ], "track 1")
    secondTrack = Track.new([ secondTrackStart], "track 2")

    world = World.new("My Data", [ homeWaypoint, storeWaypoint, firstTrack, secondTrack ])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(world.to_geojson)

    assert_equal(expected, result)
  end
end
