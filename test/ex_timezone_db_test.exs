defmodule ExTimezoneDbTest do
  use ExUnit.Case, async: false
  doctest ExTimezoneDB

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

  @invalid_zone_name "America/New_Amsterdam"

  # Tag for simplicity in setting up which tests to skip
  @premium Application.get_env(:ex_timezone_db, :premium, false)
  @notpremium !@premium

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
  end
end
