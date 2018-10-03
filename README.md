# ExTimezoneDB

**ExTimezoneDB is a simple interface to the [TimeZoneDB](https://www.timezonedb.com) REST API**

Currently, only two functions are available:
* `get_timezone_by_name` Which is used to find timezone information by name\(ie "America/New\_York\)
* `get_timezone_by_position` Which is used to find timezone information by latitude and longitude

## Installation

Add ExTimezoneDB to your `mix.exs`:

```elixir
  
  defp deps do
    [
      {:ex_timezone_db, github: "r11132a/ex_timezone_db", branch: "master"}
    ]

```

## Dependancies

ExTimezoneDB relys on HTTPoison and Poison for http requests and json parsing, respectivly.


## Usage

In `config.exs`
```elixir
  
  config :ex_timezone_db,key: YOUR_API_KEY

```

In your code:

```elixir

  {:ok,timezone_info} = ExTimezoneDB.get_timezone_by_name("America/New_York")

```

