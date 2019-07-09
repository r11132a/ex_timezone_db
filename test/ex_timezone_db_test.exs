defmodule ExTimezoneDbTest do
  use ExUnit.Case, async: false
  doctest ExTimezoneDB

  alias ExTimezoneDB.Timezone

  @valid_zone_name "America/New_York"
  @america_new_york_valid_response %{
    "countryCode" => "US",
    "countryName" => "United States",
    "zoneName" => "America/New_York",
    "abbreviation" => "EDT",
    "gmtOffset" => -14_400,
    "dst" => "1",
    "nextAbbreviation" => "EST"
    # Since we can't control these values, ignore them, for now.
    # "zoneStart": 1520751600,
    # "zoneEnd": 1541311199,
    # "timestamp": 1538563297,
    # "formatted": "2018-10-03 10:41:37"
  }

  @america_new_york_valid_struct Timezone.from_json(
                                   @america_new_york_valid_response
                                 )

  # Premium adds values
  @america_new_york_valid_premium_responses %{
    "cityName" => "",
    "regionName" => ""
  }

  @valid_latitude 34.0201613
  @valid_longitude -118.6919136
  @america_los_angeles_valid_response %{
    "countryCode" => "US",
    "countryName" => "United States",
    "zoneName" => "America/Los_Angeles",
    "abbreviation" => "PDT",
    "gmtOffset" => -25_200,
    "dst" => "1",
    "nextAbbreviation" => "PST"
  }

  # Premium adds values
  @america_los_angeles_premium_responses %{
    "cityName" => "Malibu Beach",
    "regionName" => "California"
  }

  # Valid results for getting timezone by city
  @valid_city_name "Tampa"
  @valid_country_code "US"

  @valid_tampa_city_results %{
    "currentPage" => 1,
    "totalPage" => 1,
    "zones" => [
      %{
        "abbreviation" => "MDT",
        "cityName" => "Tampa",
        "countryCode" => "US",
        "countryName" => "United States",
        "dst" => "1",
        "gmtOffset" => -21600,
        "nextAbbreviation" => "MST",
        "regionName" => "Colorado",
        "zoneName" => "America/Denver"
      },
      %{
        "abbreviation" => "EDT",
        "cityName" => "Tampa",
        "countryCode" => "US",
        "countryName" => "United States",
        "dst" => "1",
        "gmtOffset" => -14400,
        "nextAbbreviation" => "EST",
        "regionName" => "Florida",
        "zoneName" => "America/New_York"
      },
      %{
        "abbreviation" => "CDT",
        "cityName" => "Tampa",
        "countryCode" => "US",
        "countryName" => "United States",
        "dst" => "1",
        "gmtOffset" => -18000,
        "nextAbbreviation" => "CST",
        "regionName" => "Kansas",
        "zoneName" => "America/Chicago"
      }
    ]
  }

  @invalid_zone_name "America/New_Amsterdam"

  # Tag for simplicity in setting up which tests to skip
  # @premium Application.get_env(:ex_timezone_db, :premium, false)
  @premium ExTimezoneDB.get_premium()
  @notpremium !@premium

  # So we don't have to keep copying zoneStart, zoneEnd, timestamp, and 
  # formatted into the known valid responses
  defp compare_zone_values(known_valid_values, returned_zone)
       when is_map(returned_zone) do
    known_valid_values
    |> Map.keys()
    |> Enum.all?(fn key_name ->
      known_valid_values[key_name] == returned_zone[key_name]
    end)
  end

  # For structs (not going to cut it on premium tests)
  defp compare_zone_values_struct(known_valid_values, returned_zone) do
    known_valid_values["abbreviation"] == returned_zone.abbreviation and
      known_valid_values["cityName"] == returned_zone.city_name and
      known_valid_values["countryCode"] == returned_zone.country_code and
      known_valid_values["countryName"] == returned_zone.country_name and
      known_valid_values["dst"] == returned_zone.dst and
      known_valid_values["gmtOffset"] == returned_zone.gmt_offset and
      known_valid_values["regionName"] == returned_zone.region_name and
      known_valid_values["zoneName"] == returned_zone.zone_name and
      known_valid_values["nextAbbreviation"] ==
        returned_zone.next_abbreviation
  end

  # Since non-premium account must wait a second between requests, call
  # Process.sleep between tests, and keep one request per test
  setup do
    if @notpremium do
      Process.sleep(1000)
    else
      :ok
    end
  end

  describe "Premium tests" do
    @tag skip: @notpremium
    test "Should get info for America/New_York by name -- premium" do
      {:ok, results} = ExTimezoneDB.get_timezone_by_name(@valid_zone_name)

      compare_me =
        @america_new_york_valid_response
        |> Map.put("zoneStart", results["zoneStart"])
        |> Map.put("zoneEnd", results["zoneEnd"])
        |> Map.put("timestamp", results["timestamp"])
        |> Map.put("formatted", results["formatted"])
        |> Map.merge(@america_new_york_valid_premium_responses)

      assert results == compare_me
    end

    @tag skip: @notpremium
    test "Should get info for America/Los_Angeles by position -- premium" do
      {:ok, results} =
        ExTimezoneDB.get_timezone_by_position(
          @valid_latitude,
          @valid_longitude
        )

      compare_me =
        @america_los_angeles_valid_response
        |> Map.put("zoneStart", results["zoneStart"])
        |> Map.put("zoneEnd", results["zoneEnd"])
        |> Map.put("timestamp", results["timestamp"])
        |> Map.put("formatted", results["formatted"])
        |> Map.merge(@america_los_angeles_premium_responses)

      assert results == compare_me
    end

    @tag skip: @notpremium
    test "Get timezone by city name -- premium" do
      {:ok, results} =
        ExTimezoneDB.get_timezone_by_city(
          @valid_city_name,
          @valid_country_code
        )

      assert @valid_tampa_city_results["currentPage"] ==
               results["currentPage"]

      assert @valid_tampa_city_results["totalPage"] == results["totalPage"]

      assert length(@valid_tampa_city_results["zones"]) ==
               length(results["zones"])

      # Running under the (probably) bad assumption that the list will always
      # be in the same order.  This should probably be replaced with some kind
      # of get_in/2 (or other) magic
      assert compare_zone_values(
               Enum.at(@valid_tampa_city_results["zones"], 0),
               Enum.at(results["zones"], 0)
             )

      assert compare_zone_values(
               Enum.at(@valid_tampa_city_results["zones"], 1),
               Enum.at(results["zones"], 1)
             )

      assert compare_zone_values(
               Enum.at(@valid_tampa_city_results["zones"], 2),
               Enum.at(results["zones"], 2)
             )
    end
  end

  describe "Non premium tests" do
    @tag skip: @premium
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

    @tag skip: @premium
    test "Get Timezone by Name using struct" do
      {:ok, result_struct} = ExTimezoneDB.get_by_zone(@valid_zone_name)

      assert compare_zone_values_struct(
               @america_new_york_valid_response,
               result_struct
             )
    end

    @tag skip: @premium
    test "Should get info for America/Los_Angeles by position" do
      {:ok, results} =
        ExTimezoneDB.get_timezone_by_position(
          @valid_latitude,
          @valid_longitude
        )

      compare_me =
        @america_los_angeles_valid_response
        |> Map.put("zoneStart", results["zoneStart"])
        |> Map.put("zoneEnd", results["zoneEnd"])
        |> Map.put("timestamp", results["timestamp"])
        |> Map.put("formatted", results["formatted"])

      assert results == compare_me
    end
  end

  describe "Run always" do
    test "Should return error for invalid Zone name" do
      results = ExTimezoneDB.get_timezone_by_name(@invalid_zone_name)
      assert results == {:error, "FAILED - Record not found."}
    end

    test "Should return an error for nil as a zone name" do
      results = ExTimezoneDB.get_timezone_by_name(nil)
      assert results == {:error, "Zone Name cannot be nil"}
    end

    test "Get by zone using zone name" do
      {:ok, timezone} = ExTimezoneDB.get_by_zone(@valid_zone_name)

      assert timezone ==
               struct(@america_new_york_valid_struct,
                 timestamp: timezone.timestamp
               )
    end
  end
end
