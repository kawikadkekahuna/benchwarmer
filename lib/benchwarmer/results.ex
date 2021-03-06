defmodule Benchwarmer.Results do
  @moduledoc """
  Defines results of a Benchwarmer benchmark run.

  Handled as a struct with the following values:

    - n:             completed iterations
    - prev_n:        iterations run in previous cycle
    - duration:      time elapsed in μs
    - function:      the function that was executed when the benchmark was run
    - args:          the args that were used to execute the function
  """
  defstruct(
    n: 0, prev_n: 0, duration: 0, function: nil, args: nil
  )

  alias Benchwarmer.Results

  @doc """
  Returns average execution time per operation for a result, in microseconds.
  """
  @spec optime(Results) :: float
  def optime(%Results{n: 0}), do: 0.0
  def optime(%Results{duration: duration, n: n}), do: duration / n

end


# ########################################################################
# # On second thought, I think that overriding inspect makes it harder for
# # people who would be using this programmatically.
# ########################################################################
# defimpl Inspect, for: Benchwarmer.Results do
#   alias Benchwarmer.Results.Helpers
#
#   def inspect(r, _) do
#     name = "#{Inspect.inspect(r.function, nil)}"
#     content = Enum.join([
#                           "#{Helpers.pretty_time(r.duration)} sec",
#                           "#{Helpers.pretty_num(r.n)} iterations",
#                           "#{Helpers.pretty_optime(r)} μs/op"
#                         ], ", ")
#
#     """
#     #Benchwarmer.Results[#{name}]<#{content}>
#     """ |> String.rstrip
#   end
# end

defimpl String.Chars, for: Benchwarmer.Results do
  alias Benchwarmer.Results.Helpers

  def to_string(r) do
    name = "#{Inspect.inspect(r.function, nil)}"
    data = Enum.join [ "#{Helpers.pretty_time(r.duration)} sec",
                       "#{Helpers.pretty_num(r.n)} iterations",
                       "#{Helpers.pretty_optime(r)} μs/op" ], "   "

    """
    *** #{name} ***
    #{data}
    """
  end
end


defmodule Benchwarmer.Results.Helpers do
  @moduledoc false
  # Helper methods used to format Benchwarmer.Results when rendered to string or
  # inspected in iex.
  #
  # Mostly one-off string formatters. You can safely ignore these. :-)

  def pretty_optime(r) do
    Float.ceil(Benchwarmer.Results.optime(r), 2)
  end

  def pretty_time(ms) do
    Float.floor(ms/1_000_000, 1) |> Kernel.to_string
  end

  def pretty_num(n) do
    cond do
      n >= 1_000_000_000_000 ->
        Kernel.to_string(trunc(Float.floor(n/1_000_000_000_000))) <> "T"
      n >= 1_000_000_000 ->
        Kernel.to_string(trunc(Float.floor(n/1_000_000_000))) <> "B"
      n >= 1_000_000 ->
        Kernel.to_string(trunc(Float.floor(n/1_000_000))) <> "M"
      n >= 1000 ->
        Kernel.to_string(trunc(Float.floor(n/1000))) <> "K"
      true -> Kernel.to_string(n)
    end
    |> String.rjust(4)
  end

end
