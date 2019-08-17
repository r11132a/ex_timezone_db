defmodule ExTimezoneDB do
  @moduledoc """
  Provides an elixir interface to the TimeZoneDB (https://timezonedb.com)
  service.
  """

  alias ExTimezoneDB.Timezone
  # It's an attribute, since it SHOULDN'T change during execution
  # @key Application.get_env(:ex_timezone_db, :api_key)

  # Non premium TimezoneDB URL for version v2.1
  @timezonedb_url "http://api.timezonedb.com/v2.1"
  # Premium TimezoneDB URL for version v2.1
  @premium_timezonedb_url "http://vip.timezonedb.com/v2.1"

  # Since premium config value may be set via an environment variable, this'll
  # make sure only a boolean value is returned
  # The old version of this function had it's job replaced via a simplier
  # function actually in the config file.  Don't REALLY need this, but it's
  # easier than typing the Application.get_env over and over again...
  def get_premium, do: Application.get_env(:ex_timezone_db, :premium, false)

  # This came into being debugging some environment variable wierdness in
  # Windows.  May be removed, don't count on it staying around.
  def get_key, do: Application.get_env(:ex_timezone_db, :api_key)

  # Choose API endpoint based on whether or not a premium key is used.
  defp get_timezonedb_url do
    case get_premium() do
      true -> @premium_timezonedb_url
      false -> @timezonedb_url
    end
  end

  # Starting point for the get-time-zone family of functions.
  defp get_gettimezone_url do
    key = get_key()
    get_timezonedb_url() <> "/get-time-zone?key=#{key}&format=json"
  end

  # Using the zone name (or abbreviation)
  defp get_timezone_by_name_url(name),
    do: get_gettimezone_url() <> "&by=zone&zone=#{name}"

  # Using the position
  defp get_timezone_by_position_url(lat, lng),
    do: get_gettimezone_url() <> "&by=position&lat=#{lat}&lng=#{lng}"

  # Using the city name (both versions)
  defp get_timezone_by_city_url(city, country),
    do: get_gettimezone_url() <> "&by=city&city=#{city}&country=#{country}"

  defp get_timezone_by_city_url(city, region, country),
    do:
      get_gettimezone_url() <>
        "&by=city&city=#{city}&country=#{country}" <>
        "&region=#{region}"

  # Common code to process the result from Poison and return a cleaned up
  # map.
  defp process_body(body) do
    case body["status"] do
      "OK" ->
        clean_body =
          body
          |> Map.delete("status")
          |> Map.delete("message")

        {:ok, clean_body}

      _ ->
        status = body["status"]
        message = body["message"]
        {:error, "#{status} - #{message}"}
    end
  end

  # Common code for struct based calls
  defp make_request(url) do
    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- Poison.decode(response.body),
         {:ok, json_zone} <- process_body(body) do
      {:ok, Timezone.from_json(json_zone)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Takes a valid time zone name, and returns a success tuple of `:ok` and a map 
  of the response from TimeZoneDB service: 
  (countryCode,
   countryName,
   zoneName,
   abbreviation,
   gmtOffset,
   dst,
   zoneStart,
   zoneEnd,
   nextAbbreviation,
   timestamp,
   formatted)

   In the event of an error from the service, an error tuple will be returned
   of `:error` and a string of the form status - message

   ** NOTE ** When using the non-premium account, you **must** wait one second
   between requests.  This is your responsiblity!
  """
  def get_timezone_by_name(nil), do: {:error, "Zone Name cannot be nil"}

  def get_timezone_by_name(zone_name) do
    url = get_timezone_by_name_url(zone_name)

    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- Poison.decode(response.body) do
      process_body(body)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Start of the migration to the new struct based calls.  See [Timezone](ExTimezoneDB.Timezone.html)

  Accepts a string that is a valid time zone name (ie "America/New_York") or
  abbreviation ("EST") and returns a tuple indicating success/failure tuple.

  For success tuple will be:

    { :ok, ExTimezoneDB.Timezone.t }

  Failure will be of the form:

    {: error, "status - message" }

  NOTE:  When using a non-premium license key from TimezoneDB, requests **must**
  be at least 1 second apart.  This is your responsibility!
  """

  def get_by_zone(nil), do: {:error, "Must pass a zone name or abbreviation"}

  def get_by_zone(name) do
    name
    |> get_timezone_by_name_url()
    |> make_request()
  end

  @doc """
  Takes a valid position (latitude, longitude), and returns a success tuple 
  of `:ok` and a map of the response from TimeZoneDB service: 
  (countryCode,
   countryName,
   zoneName,
   abbreviation,
   gmtOffset,
   dst,
   zoneStart,
   zoneEnd,
   nextAbbreviation,
   timestamp,
   formatted)

   In the event of an error from the service, an error tuple will be returned
   of `:error` and a string of the form status - message

   Both values must be a valid float, or 
   `{:error, "Invalid <latitude/longitude> value"}` will be returned

   ** NOTE ** When using the non-premium account, you **must** wait one second
   between requests.  This is your responsiblity!
  """

  def get_timezone_by_position(lat, lng)
      when is_number(lat) and is_number(lng) do
    url = get_timezone_by_position_url(lat, lng)

    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- Poison.decode(response.body) do
      process_body(body)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_timezone_by_position(lat, _) when not is_number(lat),
    do: {:error, "Invalid Latitude"}

  def get_timezone_by_position(_, lng) when not is_number(lng),
    do: {:error, "Invalid Longitude"}

  @doc """
  NOTE: PREMIUM FUNCTION (must have a premium license key from TimezoneDB)

  Takes a valid city name and ISO 3166 country code. Returns a success tuple 
  of `:ok` and a map of the response from TimeZoneDB service. The response is
  different from the above methods since it returns a list of zones that have
  a city with that name (ie Tampa is in Florida, Colorado, and Kansas in the US)

  The top level map will contain:
  (currentPage,
   totalPage,
   zones)

  zones is a list and contains the standard zone response:
  (countryCode,
   countryName,
   zoneName,
   abbreviation,
   gmtOffset,
   dst,
   nextAbbreviation,
   cityName, 
   regionName)

   In the event of an error from the service, an error tuple will be returned
   of `:error` and a string of the form status - message

   Argument is of type string, and should be a valid city name that TimezoneDB
   recognizes

   Trying to use this function with a non-premium key will return an error
   response from TimezoneDB with the message "Invalid License Key"
  """
  def get_timezone_by_city(city_name, country_code) do
    url = get_timezone_by_city_url(city_name, country_code)

    with {:ok, response} <- HTTPoison.get(url),
         {:ok, body} <- Poison.decode(response.body) do
      process_body(body)
    else
      {:error, reason} -> {:error, reason}
    end
  end

 @doc """
  Start of the migration to the new struct based calls.  See [Timezone](ExTimezoneDB.Timezone.html)

  Accepts a string that is a valid city name (ie "Tampa") and a valid
  ISO 3611-1 alpha-2 code and returns a tuple indicating success/failure.

  For success tuple will be:

    { :ok, [ExTimezoneDB.Timezone.t] }

  Failure will be of the form:

    {: error, "status - message" }

  NOTE:  This is a Premium function.  You must have a Premium key from 
  TimezoneDB
  """

  def get_by_city(city, country) do
    city
    |> get_timezone_by_city_url(country)
    |> make_request()
  end

  def get_by_city(city, region, country) do
    city
    |> get_timezone_by_city_url(region, country)
    |> make_request()
  end
end
