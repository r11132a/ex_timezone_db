# Test config
use Mix.Config

fixup_premium = fn val ->
  case val do
    "false" -> false
    "0" -> false
    _ -> true
  end
end

config :ex_timezone_db, api_key: System.get_env("TIMEZONE_DB_API_KEY")
config :ex_timezone_db, premium: fixup_premium.(System.get_env("TIMEZONE_DB_PREMIUM","false"))

