defmodule TimezoneStructTest do
  use ExUnit.Case, async: false
  doctest ExTimezoneDB.Timezone

  alias ExTimezoneDB.Timezone

  @latitude 34.0201613
  @longitude -118.6919136

  @valid_values %{
    country_code: "US",
    country_name: "United States",
    zone_name: "America/Los_Angeles",
    abbreviation: "PDT",
    gmt_offset: -25_200,
    dst: "1",
    next_abbreviation: "PST"
  }

  @premium_valid_values %{
    city_name: "Malibu Beach",
    region_name: "California"
  }

  @premium ExTimezoneDB.get_premium()
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

  describe "Premium Tests" do
    @tag skip: @notpremium
    test "Should correctly populate via ExTimezoneDB.Timezone.from_json" do
      {:ok, results} =
        ExTimezoneDB.get_timezone_by_position(@latitude, @longitude)

      timezone = Timezone.from_json(results)
      assert timezone.country_code == Map.get(@valid_values, :country_code)
      assert timezone.country_name == Map.get(@valid_values, :country_name)
      assert timezone.zone_name == Map.get(@valid_values, :zone_name)
      assert timezone.abbreviation == Map.get(@valid_values, :abbreviation)
      assert timezone.gmt_offset == Map.get(@valid_values, :gmt_offset)
      assert timezone.dst == Map.get(@valid_values, :dst)

      assert timezone.next_abbreviation ==
               Map.get(@valid_values, :next_abbreviation)

      assert timezone.city_name == Map.get(@premium_valid_values, :city_name)

      assert timezone.region_name ==
               Map.get(@premium_valid_values, :region_name)
    end
  end

  describe "Non premium tests" do
    @tag skip: @premium
    test "Should correctly populate via ExTimezoneDB.Timezone.from_json" do
      {:ok, results} =
        ExTimezoneDB.get_timezone_by_position(@latitude, @longitude)

      timezone = Timezone.from_json(results)
      assert timezone.country_code == Map.get(@valid_values, :country_code)
      assert timezone.country_name == Map.get(@valid_values, :country_name)
      assert timezone.zone_name == Map.get(@valid_values, :zone_name)
      assert timezone.abbreviation == Map.get(@valid_values, :abbreviation)
      assert timezone.gmt_offset == Map.get(@valid_values, :gmt_offset)
      assert timezone.dst == Map.get(@valid_values, :dst)

      assert timezone.next_abbreviation ==
               Map.get(@valid_values, :next_abbreviation)

      # Should be nil if not using a premium key
      assert timezone.city_name == nil
      assert timezone.region_name == nil
    end
  end
end
