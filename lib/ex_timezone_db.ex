defmodule ExTimezoneDB do
  @moduledoc """
  Provides an elixir interface to the TimeZoneDB (https://timezonedb.com)
  service.
  """
  # It's an attribute, since it SHOULDN'T change during execution
  @key Application.get_env(:ex_timezone_db, :api_key)

  # Non premium TimezoneDB URL for version v2.1
  @timezonedb_url "http://api.timezonedb.com/v2.1"
  # Premium TimezoneDB URL for version v2.1
  @premium_timezonedb_url "http://vip.timezonedb.com/v2.1"

  # Note: This isn't an attributes mostly for testing...so we can switch 
  # between keys.  The overhead is low enough that it shouldn't be a problem.
  defp get_timezonedb_url() do
    case Application.get_env(:ex_timezone_db, :premium, false) do
      true -> @premium_timezonedb_url
      false -> @timezonedb_url
    end
  end

  defp get_gettimezone_url(),
    do: get_timezonedb_url() <> "/get-time-zone?key=#{@key}&format=json"

  defp get_timezone_by_name_url(name),
    do: get_gettimezone_url() <> "&by=zone&zone=#{name}"

  defp get_timezone_by_position_url(lat, lng),
    do: get_gettimezone_url() <> "&by=position&lat=#{lat}&lng=#{lng}"

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
end
