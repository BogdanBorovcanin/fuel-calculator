# FuelCalculator
  
## Running

Please run with following command: 

```elixir
mix run lib/cli/cli.exs '28801, [{:launch, "earth"}, {:land, "moon"}, {:launch, "moon"}, {:land, "earth"}]'
```
  
Kindly ensure that the arguments are formatted as one string since parsing arguments that include commas is exceedingly challenging via the command-line interface.
