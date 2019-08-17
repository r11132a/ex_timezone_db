defmodule ExTimezoneDB.Timezone do
  @moduledoc """
  Defines the structure and ancillary functions handling the valid return 
  data from the TimezoneDB service.

  TimezoneDB returns for each zone
  - countryName (as a string)
  - countryCode (as ISO 3166-1 alpha-2 codes (2 letter codes))
  - zoneName  (as a string representing the IANA time zone database entries)
  - abbreviation (as the one to four letter abbreviation of the zone)
  - nextAbbreviation (as the one to four letter abbreviation of the next zone)
  - gmtOffset (as an integer of seconds of offset from GMT)
  - dst (as string "0" for No or "1" for Yes)
  - timestamp (as a Unix time as the current time for the zone)

  Values returned by TimezoneDB which are ignored
  - zoneStart
  - zoneStop
  - formatted

  In addition, if using a premium key TimezoneDB may (depending on the request)
  return two other fields for a zone
  - cityName
  - regionName

  These are packaged into a struct with the following fields
  - country_code
  - country_name
  - zone_name
  - abbreviation
  - next_abbreviation
  - gmt_offset
  - dst
  - timestamp
  - city_name
  - region_name

  """
  defstruct [
    :country_code,
    :country_name,
    :zone_name,
    :abbreviation,
    :gmt_offset,
    :dst,
    :next_abbreviation,
    :timestamp,
    # These last two are only populated for premium requests
    :city_name,
    :region_name
  ]

  @type t :: %__MODULE__{
          country_code: String.t(),
          country_name: String.t(),
          zone_name: String.t(),
          abbreviation: String.t(),
          gmt_offset: integer,
          dst: String.t(),
          next_abbreviation: String.t(),
          timestamp: non_neg_integer(),
          city_name: String.t() | nil,
          region_name: String.t() | nil
        }

  alias ExTimezoneDB.Timezone

  defp no_empty_string(str) do
    case str do
      "" -> nil
      str -> str
    end
  end

  @doc """
  Converts the zone info from the response to a Timezone struct
  """
  @spec from_json(Map.t()) :: Timezone.t()

  def from_json(json_map) do
    struct(%Timezone{},
      country_code: json_map["countryCode"],
      country_name: json_map["countryName"],
      zone_name: json_map["zoneName"],
      abbreviation: json_map["abbreviation"],
      gmt_offset: json_map["gmtOffset"],
      dst: json_map["dst"],
      next_abbreviation: json_map["nextAbbreviation"],
      timestamp: json_map["timestamp"],
      city_name: no_empty_string(json_map["cityName"]),
      region_name: no_empty_string(json_map["regionName"])
    )
  end
end
