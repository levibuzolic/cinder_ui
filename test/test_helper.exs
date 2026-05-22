defmodule CinderUI.TestHelpers do
  @moduledoc false

  def slot(content) when is_binary(content) do
    [%{inner_block: fn _, _ -> content end}]
  end

  def slot(fun) when is_function(fun, 0) do
    [%{inner_block: fn _, _ -> fun.() end}]
  end

  def slot(content, attrs) when is_binary(content) and is_map(attrs) do
    [%{inner_block: fn _, _ -> content end} |> Map.merge(attrs)]
  end

  def parse_html(html) when is_binary(html) do
    html
    |> Floki.parse_document!()
  end

  def find_one!(html_or_doc, selector) do
    case Floki.find(as_doc(html_or_doc), selector) do
      [node | _] -> node
      [] -> raise "expected selector #{inspect(selector)} to match at least one node"
    end
  end

  def find_all(html_or_doc, selector) do
    Floki.find(as_doc(html_or_doc), selector)
  end

  def text(html_or_doc, selector) do
    html_or_doc
    |> find_one!(selector)
    |> Floki.text(sep: " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  def attr(html_or_doc, selector, name) do
    html_or_doc
    |> find_one!(selector)
    |> Floki.attribute(name)
    |> List.first()
  end

  def has_class?(html_or_doc, selector, class_name) do
    html_or_doc
    |> attr(selector, "class")
    |> to_string()
    |> String.split()
    |> Enum.member?(class_name)
  end

  defp as_doc(html) when is_binary(html), do: parse_html(html)
  defp as_doc(doc), do: doc
end

Code.require_file("support/generated_assets.exs", __DIR__)
CinderUI.GeneratedAssetsSupport.ensure_demo_assets!()

ExUnit.start()
