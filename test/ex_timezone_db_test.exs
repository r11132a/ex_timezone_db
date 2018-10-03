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

  test "should get info for America/New_York" do
    {:ok, results} = ExTimezoneDB.get_timezone_by_name(@valid_zone_name)

    compare_me =
      @america_new_york_valid_response
      |> Map.put("zoneStart", results["zoneStart"])
      |> Map.put("zoneEnd", results["zoneEnd"])
      |> Map.put("timestamp", results["timestamp"])
      |> Map.put("formatted", results["formatted"])

    assert results == compare_me
  end
end
