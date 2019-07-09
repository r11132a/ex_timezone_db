# Test config
use Mix.Config

# Used to fixup the premium config value, which is preferred to be a boolean
# but that is impossible when pulling from the environment.  So, use this when
# using System.get_env/1 to prevent nastiness later, please.
fixup_premium = fn val ->
  case val do
    "false" -> false
    "0" -> false
    nil -> false
    _ -> true
  end
end

config :ex_timezone_db, api_key: System.get_env("TIMEZONE_DB_API_KEY")

config :ex_timezone_db,
  premium: fixup_premium.(System.get_env("TIMEZONE_DB_PREMIUM"))
