defmodule CF do
  defmacro unless(expr, do: block) do
    quote do
      case !unquote(expr) do
        judge when judge in [false, nil] ->
          nil
        _ ->
          unquote(block)
      end
    end
  end
end
