defmodule Translator do
  defmacro __using__(_opt) do
    quote do
      Module.register_attribute __MODULE__, :locales, accumulate: true,
        persist: false
      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end
  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :locales)) #env is top level context?
  end
  defmacro locale(name, mappings) do
    quote bind_quoted: [name: name, mappings: mappings] do
      @locales {name, mappings}
    end
  end
  def compile(translations) do
    translations_ast = for {locale, mappings} <- translations do
      deftranslations(locale, "", mappings)
    end
    final_ast = quote do
      def t(locales, path, bindings \\ [])
      unquote(translations_ast)
      def t(_locale, _path, _bindings), do: {:error, :no_tranlation}
    end
    IO.puts Macro.to_string(final_ast)
    final_ast
  end
  defp deftranslations(locale, current_path, mappings) do
    for {key, val} <- mappings do
      path = append_path(current_path, key)
      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
          def t(unquote(locale), unquote(path), bindings) do
            unquote(interpolate(val))
          end
        end
      end
    end
  end
  defp interpolate(map) when is_map(map) do
    quote do
      case bindings do
        [count: x] when x < 1 -> unquote(map.none)
        [count: x] when x == 1 -> unquote(map.single)
        [count: x] when x > 1 -> unquote(map.plural)
      end
    end
  end
  defp interpolate(string) do
    ~r/(?<head>)%{[^}]+}(?<tail>)/
    |> Regex.split(string, on: [:head, :tail]) #["Hello ", "%{first}", " ", "%{last}", "!"]
    |> Enum.reduce("", fn
      << "%{" <> rest >>, acc ->  #pattern match & rest will be first} or last}
        key = String.to_atom(String.trim_trailing(rest, "}")) # key will be :first or :last
        quote do
          unquote(acc) <> to_string(Keyword.fetch!(bindings, unquote(key)))
        end
      segment, acc -> # pattern match & segment will be Hello, "", !
        quote do: (unquote(acc) <> unquote(segment))
   end)
  end
  defp append_path("", next), do:  to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"
end
