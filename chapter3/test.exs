defmodule Mime do
  a = :"mishiro"
  b = :eiji
  lhs = "lhs"
  rhs = "rhs"
  def unquote(a)(test) do
    IO.inspect unquote(b)
    IO.inspect test
    c = 1
    d = 2
    quote do
      unquote(b)
    end
  end
  c = defmacro say({:+, _, [lhs, rhs]}) do
    unquote(b)
    IO.inspect unquote(lhs)
    IO.inspect unquote(rhs)
    ast = quote do
      unquote(lhs) + unquote(rhs)
    end
    IO.inspect ast
    IO.inspect Code.eval_quoted ast
  end
end
