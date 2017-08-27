defmodule AST do
  defmacro quote(do: block = {expr, meta, value}) do
    IO.inspect(expr)
    Quoter.parse(block)
  end
end

defmodule Quoter do
  def parse({:unquote, meta, value}) do
    IO.inspect(__ENV__.vars)
  end
  def parse({expr, meta, value}) do
    case value do
      {lhs, rhs} when is_tuple(lhs)-> parse(lhs)
      {lhs, rhs} when is_tuple(rhs)-> parse(lhs)
      _ -> IO.puts {expr, ["origin"], value}
    end
  end
  def parse(value), do: value
end
