# ExTimezoneDB

![Travis CI Build Status](https://api.travis-ci.org/r11132a/ex_timezone_db.svg?branch=master)

**ExTimezoneDB is a simple interface to the [TimeZoneDB](https://www.timezonedb.com) REST API**

Currently, only three functions are available:
* `get_timezone_by_name` Which is used to find timezone information by name\(ie "America/New\_York"\)
* `get_timezone_by_position` Which is used to find timezone information by latitude and longitude
* `get_timezone_by_city` Which is used to find timezone(s) by using the name of
the city.  Potentially returns mutliple time zones.

## Installation

Add ExTimezoneDB to your `mix.exs`:

```elixir
  
  defp deps do
    [
      {:ex_timezone_db, github: "r11132a/ex_timezone_db", branch: "master"}
    ]

```

## Dependencies

ExTimezoneDB relies on HTTPoison and Poison for http requests and json parsing, respectivly.


## Usage

In `config.exs`
```elixir
  
  config :ex_timezone_db,api_key: YOUR_API_KEY

```
The following is optional (defaults to false), but should be set if you have
a Premium key (value is a boolean)
```elixir

  config :ex_timezone_db, premium: true

```

In your code:

```elixir

  {:ok,timezone_info} = ExTimezoneDB.get_timezone_by_name("America/New_York")

```

