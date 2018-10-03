defmodule ExTimezoneDbTest do
  use ExUnit.Case
  doctest ExTimezoneDB

  @valid_zone_name "America/New_York"
  @america_new_york_valid_response %{
    "countryCode" => "US",
    "countryName" => "United States",
    "zoneName" => "America/New_York",
    "abbreviation" => "EDT",
    "gmtOffset" => -14400,
    "dst" => "1",
    "nextAbbreviation" => "EST"
    # Since we can't control these values, ignore them, for now.
    # "zoneStart": 1520751600,
    # "zoneEnd": 1541311199,
    # "timestamp": 1538563297,
    # "formatted": "2018-10-03 10:41:37"
  }

  @valid_latitude 34.0201613
  @valid_longitude -118.6919136
  @america_los_angeles_valid_response %{
    "countryCode" => "US",
    "countryName" => "United States",
    "zoneName" => "America/Los_Angeles",
    "abbreviation" => "PDT",
    "gmtOffset" => -25200,
    "dst" => "1",
    "nextAbbreviation" => "PST"
  }

  @invalid_zone_name "America/New_Amsterdam"

  # Since non-premium account must wait a second between requests, call
  # Process.sleep between tests, and keep one request per test
  setup do
    Process.sleep(1000)
  end

  test "Should get info for America/New_York by name" do
    {:ok, results} = ExTimezoneDB.get_timezone_by_name(@valid_zone_name)

    compare_me =
      @america_new_york_valid_response
      |> Map.put("zoneStart", results["zoneStart"])
      |> Map.put("zoneEnd", results["zoneEnd"])
      |> Map.put("timestamp", results["timestamp"])
      |> Map.put("formatted", results["formatted"])

    assert results == compare_me
  end

  test "Should return error for invalid Zone name" do
    results = ExTimezoneDB.get_timezone_by_name(@invalid_zone_name)
    assert results == {:error, "FAILED - Record not found."}
  end

  test "Should get info for America/Los_Angeles by position" do
    {:ok, results} =
      ExTimezoneDB.get_timezone_by_position(@valid_latitude, @valid_longitude)

    compare_me =
      @america_los_angeles_valid_response
      |> Map.put("zoneStart", results["zoneStart"])
      |> Map.put("zoneEnd", results["zoneEnd"])
      |> Map.put("timestamp", results["timestamp"])
      |> Map.put("formatted", results["formatted"])

    assert results == compare_me
  end
end
