ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Advisor.Repo, :manual)

