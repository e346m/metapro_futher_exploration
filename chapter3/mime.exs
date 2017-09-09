defmodule Mime do
  @external_resouce @mime_path Path.join([__DIR__, "mime.txt"])
  defmacro __using__(options) do
    quote do
      unquote(from_(options))
      unquote(from_file)
      def exts_from_type(_type), do: []
      def type_from_ext(_ext), do: nil
      def valid_type?(type), do: type |> exts_from_type |> Enum.any?
    end
  end
  def from_file do
    for line <- File.stream!(@mime_path, [], :line) do
      [type, rest] = String.split(line, ";")
      extentions = rest |> String.trim |> String.split(~r/,\s?/)
      quote do
        def exts_from_type(unquote(type)), do: unquote(extentions)
        def type_from_ext(ext) when ext in unquote(extentions), do: unquote(type)
      end
    end
  end
  def from_(options) do
    for {key, exts} <- options do
      type = Atom.to_string(key)
      quote do
        def exts_from_type(unquote(type)), do: unquote(exts)
      end
    end
  end
end
