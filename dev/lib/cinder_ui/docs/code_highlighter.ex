defmodule CinderUI.Docs.CodeHighlighter do
  @moduledoc false

  @keywords MapSet.new(~w(true false nil do end fn if else case when with for in))
  @elixir_keywords MapSet.new(~w(
                       true false nil do end fn if else case when with for in
                       def defp defmodule use alias import require quote unquote
                       try catch rescue receive after cond
                     ))
  @bash_keywords MapSet.new(~w(mix cd npm pnpm yarn bun))

  @type language :: :auto | :heex | :elixir | :css | :bash | :plain

  @spec highlight(String.t(), language()) :: String.t()
  def highlight(source, language \\ :auto) when is_binary(source) do
    case resolve_language(source, language) do
      :heex -> highlight_heex(source)
      :elixir -> highlight_elixir(source)
      :css -> highlight_css(source)
      :bash -> highlight_bash(source)
      :plain -> escape_html(source)
    end
  end

  @spec unescape_html(String.t()) :: String.t()
  def unescape_html(value) when is_binary(value) do
    value
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.replace("&amp;", "&")
  end

  @spec heex_like?(String.t()) :: boolean()
  def heex_like?(source) when is_binary(source) do
    String.contains?(source, "<.") or
      String.contains?(source, "</.") or
      String.contains?(source, "<:") or
      String.contains?(source, "</:")
  end

  @spec escape_html(String.t()) :: String.t()
  def escape_html(value) when is_binary(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  defp resolve_language(source, :auto), do: if(heex_like?(source), do: :heex, else: :plain)

  defp resolve_language(_source, language) when language in [:heex, :elixir, :css, :bash, :plain],
    do: language

  defp resolve_language(_source, _language), do: :plain

  defp highlight_heex(source), do: highlight_heex(source, 0, [])

  defp highlight_heex(source, idx, out) when idx >= byte_size(source) do
    out |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp highlight_heex(source, idx, out) do
    cond do
      starts_with?(source, idx, "<!--") ->
        {chunk, next_idx} = take_until(source, idx, "-->", 4)

        highlight_heex(source, next_idx, [
          [~s(<span class="tok-comment">), escape_html(chunk), "</span>"] | out
        ])

      at(source, idx) == ?< ->
        case take_until_char(source, idx, ?>, 1) do
          {tag, next_idx} ->
            highlight_heex(source, next_idx, [highlight_tag(tag) | out])

          :not_found ->
            rest = binary_part(source, idx, byte_size(source) - idx)
            highlight_heex(source, byte_size(source), [escape_html(rest) | out])
        end

      at(source, idx) == ?{ ->
        {chunk, next_idx} = read_balanced(source, idx, ?{, ?})
        highlight_heex(source, next_idx, [highlight_expression(chunk) | out])

      true ->
        {text, next_idx} = take_while(source, idx, fn char -> char != ?< and char != ?{ end)

        highlight_heex(source, next_idx, [
          [~s(<span class="tok-text">), escape_html(text), "</span>"] | out
        ])
    end
  end

  defp highlight_tag("<!--" <> _ = tag),
    do: ~s(<span class="tok-comment">#{escape_html(tag)}</span>)

  defp highlight_tag(tag) do
    closing = String.starts_with?(tag, "</")
    self_closing = String.ends_with?(tag, "/>")
    close_token = if(self_closing, do: "/>", else: ">")
    cursor = if(closing, do: 2, else: 1)
    open_punct = if(closing, do: "&lt;/", else: "&lt;")

    {tag_name, cursor} = take_while(tag, cursor, &tag_name_char?/1)

    out = [
      ~s(<span class="tok-tag">#{escape_html(tag_name)}</span>),
      ~s(<span class="tok-punct">#{open_punct}</span>)
    ]

    out =
      highlight_tag_rest(
        tag,
        cursor,
        byte_size(tag) - byte_size(close_token),
        out
      )

    [
      Enum.reverse(out),
      ~s(<span class="tok-punct">#{if(close_token == "/>", do: "/&gt;", else: "&gt;")}</span>)
    ]
    |> IO.iodata_to_binary()
  end

  defp highlight_tag_rest(_tag, cursor, stop, out) when cursor >= stop, do: out

  defp highlight_tag_rest(tag, cursor, stop, out) do
    char = at(tag, cursor)

    cond do
      whitespace?(char) ->
        highlight_tag_rest(tag, cursor + 1, stop, [<<char>> | out])

      char == ?{ ->
        {chunk, next_cursor} = read_balanced(tag, cursor, ?{, ?})
        highlight_tag_rest(tag, next_cursor, stop, [highlight_expression(chunk) | out])

      char in [?", ?'] ->
        {chunk, next_cursor} = take_string(tag, cursor, char)

        highlight_tag_rest(
          tag,
          next_cursor,
          stop,
          [[~s(<span class="tok-string">), escape_html(chunk), "</span>"] | out]
        )

      char == ?= ->
        highlight_tag_rest(tag, cursor + 1, stop, [
          [~s(<span class="tok-operator">=</span>)] | out
        ])

      char == ?/ ->
        highlight_tag_rest(tag, cursor + 1, stop, [[~s(<span class="tok-punct">/</span>)] | out])

      attr_char_start?(char) ->
        {name, next_cursor} = take_while(tag, cursor, &attr_char?/1)

        highlight_tag_rest(
          tag,
          next_cursor,
          stop,
          [[~s(<span class="tok-attr">), escape_html(name), "</span>"] | out]
        )

      true ->
        highlight_tag_rest(tag, cursor + 1, stop, [escape_html(<<char>>) | out])
    end
  end

  defp highlight_expression(expr) do
    [~s(<span class="tok-expr">), highlight_expression_tokens(expr, 0, []), "</span>"]
    |> IO.iodata_to_binary()
  end

  defp highlight_expression_tokens(expr, idx, out) when idx >= byte_size(expr) do
    out |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp highlight_expression_tokens(expr, idx, out) do
    char = at(expr, idx)

    cond do
      char in [?{, ?}] ->
        highlight_expression_tokens(
          expr,
          idx + 1,
          [[~s(<span class="tok-punct">), escape_html(<<char>>), "</span>"] | out]
        )

      char in [?", ?'] ->
        {chunk, next_idx} = take_string(expr, idx, char)

        highlight_expression_tokens(
          expr,
          next_idx,
          [[~s(<span class="tok-string">), escape_html(chunk), "</span>"] | out]
        )

      char == ?: and ident_start?(safe_at(expr, idx + 1)) ->
        {chunk, next_idx} = take_while(expr, idx + 1, &ident_char?/1)
        atom = ":" <> chunk

        highlight_expression_tokens(
          expr,
          next_idx,
          [[~s(<span class="tok-atom">), escape_html(atom), "</span>"] | out]
        )

      digit?(char) ->
        {number, next_idx} = take_while(expr, idx, fn c -> digit?(c) or c in [?., ?_] end)

        highlight_expression_tokens(
          expr,
          next_idx,
          [[~s(<span class="tok-number">), escape_html(number), "</span>"] | out]
        )

      ident_start?(char) ->
        {word, next_idx} = take_while(expr, idx, &ident_char?/1)
        klass = if(MapSet.member?(@keywords, word), do: "tok-keyword", else: "tok-ident")

        highlight_expression_tokens(
          expr,
          next_idx,
          [[~s(<span class="#{klass}">), escape_html(word), "</span>"] | out]
        )

      operator?(char) ->
        {op, next_idx} = take_while(expr, idx, &operator?/1)

        highlight_expression_tokens(
          expr,
          next_idx,
          [[~s(<span class="tok-operator">), escape_html(op), "</span>"] | out]
        )

      punct?(char) ->
        highlight_expression_tokens(
          expr,
          idx + 1,
          [[~s(<span class="tok-punct">), escape_html(<<char>>), "</span>"] | out]
        )

      true ->
        highlight_expression_tokens(expr, idx + 1, [escape_html(<<char>>) | out])
    end
  end

  defp highlight_css(source), do: highlight_css(source, 0, [])

  defp highlight_css(source, idx, out) when idx >= byte_size(source) do
    out |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp highlight_css(source, idx, out) do
    cond do
      starts_with?(source, idx, "/*") ->
        {chunk, next_idx} = take_until(source, idx, "*/", 2)

        highlight_css(source, next_idx, [
          [~s(<span class="tok-comment">), escape_html(chunk), "</span>"] | out
        ])

      at(source, idx) in [?", ?'] ->
        {chunk, next_idx} = take_string(source, idx, at(source, idx))

        highlight_css(source, next_idx, [
          [~s(<span class="tok-string">), escape_html(chunk), "</span>"] | out
        ])

      at(source, idx) == ?@ ->
        {word, next_idx} = take_while(source, idx + 1, &css_ident_char?/1)
        token = "@" <> word

        highlight_css(source, next_idx, [
          [~s(<span class="tok-keyword">), escape_html(token), "</span>"] | out
        ])

      at(source, idx) == ?# and hex_color_start?(source, idx) ->
        {value, next_idx} = take_while(source, idx + 1, &hex_char?/1)
        token = "#" <> value

        highlight_css(source, next_idx, [
          [~s(<span class="tok-number">), escape_html(token), "</span>"] | out
        ])

      digit?(at(source, idx)) ->
        {number, next_idx} = take_while(source, idx, fn c -> digit?(c) or c in [?., ?_] end)
        {unit, final_idx} = take_while(source, next_idx, &css_ident_char?/1)
        token = number <> unit

        highlight_css(source, final_idx, [
          [~s(<span class="tok-number">), escape_html(token), "</span>"] | out
        ])

      starts_with?(source, idx, "--") and css_ident_char?(safe_at(source, idx + 2)) ->
        {name, next_idx} = take_while(source, idx + 2, &css_ident_char?/1)
        token = "--" <> name

        highlight_css(source, next_idx, [
          [~s(<span class="tok-attr">), escape_html(token), "</span>"] | out
        ])

      css_ident_start?(at(source, idx)) ->
        {name, next_idx} = take_while(source, idx, &css_ident_char?/1)
        next_non_ws = skip_whitespace(source, next_idx)
        klass = if(safe_at(source, next_non_ws) == ?:, do: "tok-attr", else: "tok-ident")

        highlight_css(source, next_idx, [
          [~s(<span class="#{klass}">), escape_html(name), "</span>"] | out
        ])

      at(source, idx) in [?{, ?}, ?(, ?), ?[, ?], ?;, ?:, ?,] ->
        highlight_css(
          source,
          idx + 1,
          [[~s(<span class="tok-punct">), escape_html(<<at(source, idx)>>), "</span>"] | out]
        )

      at(source, idx) in [?=, ?+, ?-, ?*, ?/, ?>, ?<, ?!, ?|, ?&, ?.] ->
        {op, next_idx} =
          take_while(source, idx, fn c -> c in [?=, ?+, ?-, ?*, ?/, ?>, ?<, ?!, ?|, ?&, ?.] end)

        highlight_css(source, next_idx, [
          [~s(<span class="tok-operator">), escape_html(op), "</span>"] | out
        ])

      true ->
        highlight_css(source, idx + 1, [escape_html(<<at(source, idx)>>) | out])
    end
  end

  defp highlight_elixir(source), do: highlight_elixir(source, 0, [])

  defp highlight_elixir(source, idx, out) when idx >= byte_size(source) do
    out |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp highlight_elixir(source, idx, out) do
    cond do
      starts_with?(source, idx, "#") ->
        {comment, next_idx} = take_until_char_or_eof(source, idx, ?\n)

        highlight_elixir(source, next_idx, [
          [~s(<span class="tok-comment">), escape_html(comment), "</span>"] | out
        ])

      at(source, idx) in [?", ?'] ->
        {chunk, next_idx} = take_string(source, idx, at(source, idx))

        highlight_elixir(source, next_idx, [
          [~s(<span class="tok-string">), escape_html(chunk), "</span>"] | out
        ])

      at(source, idx) == ?: and ident_start?(safe_at(source, idx + 1)) ->
        {word, next_idx} = take_while(source, idx + 1, &ident_char?/1)
        token = ":" <> word

        highlight_elixir(source, next_idx, [
          [~s(<span class="tok-atom">), escape_html(token), "</span>"] | out
        ])

      digit?(at(source, idx)) ->
        {number, next_idx} = take_while(source, idx, fn c -> digit?(c) or c in [?., ?_] end)

        highlight_elixir(source, next_idx, [
          [~s(<span class="tok-number">), escape_html(number), "</span>"] | out
        ])

      tag_name_char?(at(source, idx)) ->
        {word, next_idx} = take_while(source, idx, &tag_name_char?/1)
        klass = if(MapSet.member?(@elixir_keywords, word), do: "tok-keyword", else: "tok-ident")

        highlight_elixir(source, next_idx, [
          [~s(<span class="#{klass}">), escape_html(word), "</span>"] | out
        ])

      operator?(at(source, idx)) ->
        {op, next_idx} = take_while(source, idx, &operator?/1)

        highlight_elixir(source, next_idx, [
          [~s(<span class="tok-operator">), escape_html(op), "</span>"] | out
        ])

      punct_or_block_char?(at(source, idx)) ->
        highlight_elixir(
          source,
          idx + 1,
          [[~s(<span class="tok-punct">), escape_html(<<at(source, idx)>>), "</span>"] | out]
        )

      true ->
        highlight_elixir(source, idx + 1, [escape_html(<<at(source, idx)>>) | out])
    end
  end

  defp highlight_bash(source), do: highlight_bash(source, 0, [])

  defp highlight_bash(source, idx, out) when idx >= byte_size(source) do
    out |> Enum.reverse() |> IO.iodata_to_binary()
  end

  defp highlight_bash(source, idx, out) do
    cond do
      starts_with?(source, idx, "#") ->
        {comment, next_idx} = take_until_char_or_eof(source, idx, ?\n)

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-comment">), escape_html(comment), "</span>"] | out
        ])

      at(source, idx) in [?", ?'] ->
        {chunk, next_idx} = take_string(source, idx, at(source, idx))

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-string">), escape_html(chunk), "</span>"] | out
        ])

      at(source, idx) == ?$ and ident_start?(safe_at(source, idx + 1)) ->
        {word, next_idx} = take_while(source, idx + 1, &ident_char?/1)
        token = "$" <> word

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-atom">), escape_html(token), "</span>"] | out
        ])

      starts_with?(source, idx, "--") and css_ident_char?(safe_at(source, idx + 2)) ->
        {name, next_idx} = take_while(source, idx + 2, &css_ident_char?/1)
        token = "--" <> name

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-attr">), escape_html(token), "</span>"] | out
        ])

      digit?(at(source, idx)) ->
        {number, next_idx} = take_while(source, idx, fn c -> digit?(c) or c in [?., ?_] end)

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-number">), escape_html(number), "</span>"] | out
        ])

      ident_start?(at(source, idx)) ->
        {word, next_idx} = take_while(source, idx, &ident_char?/1)
        klass = if(MapSet.member?(@bash_keywords, word), do: "tok-keyword", else: "tok-ident")

        highlight_bash(source, next_idx, [
          [~s(<span class="#{klass}">), escape_html(word), "</span>"] | out
        ])

      operator?(at(source, idx)) ->
        {op, next_idx} = take_while(source, idx, &operator?/1)

        highlight_bash(source, next_idx, [
          [~s(<span class="tok-operator">), escape_html(op), "</span>"] | out
        ])

      bash_punct?(at(source, idx)) ->
        highlight_bash(
          source,
          idx + 1,
          [[~s(<span class="tok-punct">), escape_html(<<at(source, idx)>>), "</span>"] | out]
        )

      true ->
        highlight_bash(source, idx + 1, [escape_html(<<at(source, idx)>>) | out])
    end
  end

  defp read_balanced(source, start_idx, open_char, close_char) do
    read_balanced(source, start_idx, open_char, close_char, 0, nil, start_idx)
  end

  defp read_balanced(source, idx, _open, _close, _depth, _quote, start_idx)
       when idx >= byte_size(source) do
    {binary_part(source, start_idx, byte_size(source) - start_idx), byte_size(source)}
  end

  defp read_balanced(source, idx, open_char, close_char, depth, quote, start_idx) do
    char = at(source, idx)

    cond do
      not is_nil(quote) ->
        cond do
          char == ?\\ ->
            read_balanced(
              source,
              min(idx + 2, byte_size(source)),
              open_char,
              close_char,
              depth,
              quote,
              start_idx
            )

          char == quote ->
            read_balanced(source, idx + 1, open_char, close_char, depth, nil, start_idx)

          true ->
            read_balanced(source, idx + 1, open_char, close_char, depth, quote, start_idx)
        end

      char in [?", ?'] ->
        read_balanced(source, idx + 1, open_char, close_char, depth, char, start_idx)

      char == open_char ->
        read_balanced(source, idx + 1, open_char, close_char, depth + 1, nil, start_idx)

      char == close_char ->
        new_depth = depth - 1

        if new_depth == 0 do
          {binary_part(source, start_idx, idx - start_idx + 1), idx + 1}
        else
          read_balanced(source, idx + 1, open_char, close_char, new_depth, nil, start_idx)
        end

      true ->
        read_balanced(source, idx + 1, open_char, close_char, depth, nil, start_idx)
    end
  end

  defp take_until(source, idx, terminator, terminator_size) do
    case :binary.match(binary_part(source, idx, byte_size(source) - idx), terminator) do
      {offset, _len} ->
        final_idx = idx + offset + terminator_size
        {binary_part(source, idx, final_idx - idx), final_idx}

      :nomatch ->
        {binary_part(source, idx, byte_size(source) - idx), byte_size(source)}
    end
  end

  defp take_until_char(source, idx, char, step) do
    take_until_char(source, idx, char, step, idx)
  end

  defp take_until_char(source, idx, _char, _step, _start) when idx >= byte_size(source),
    do: :not_found

  defp take_until_char(source, idx, char, step, start) do
    if at(source, idx) == char do
      next_idx = idx + step
      {binary_part(source, start, next_idx - start), next_idx}
    else
      take_until_char(source, idx + 1, char, step, start)
    end
  end

  defp take_until_char_or_eof(source, idx, char) do
    case take_until_char(source, idx, char, 1) do
      {chunk, next_idx} -> {chunk, next_idx}
      :not_found -> {binary_part(source, idx, byte_size(source) - idx), byte_size(source)}
    end
  end

  defp take_string(source, idx, quote_char) do
    take_string(source, idx + 1, quote_char, idx)
  end

  defp take_string(source, idx, _quote_char, start) when idx >= byte_size(source) do
    {binary_part(source, start, byte_size(source) - start), byte_size(source)}
  end

  defp take_string(source, idx, quote_char, start) do
    char = at(source, idx)

    cond do
      char == ?\\ ->
        take_string(source, min(idx + 2, byte_size(source)), quote_char, start)

      char == quote_char ->
        next_idx = idx + 1
        {binary_part(source, start, next_idx - start), next_idx}

      true ->
        take_string(source, idx + 1, quote_char, start)
    end
  end

  defp take_while(source, idx, _fun) when idx >= byte_size(source), do: {"", idx}

  defp take_while(source, idx, fun) do
    take_while(source, idx, idx, fun)
  end

  defp take_while(source, idx, start, _fun) when idx >= byte_size(source) do
    {binary_part(source, start, idx - start), idx}
  end

  defp take_while(source, idx, start, fun) do
    if fun.(at(source, idx)) do
      take_while(source, idx + 1, start, fun)
    else
      {binary_part(source, start, idx - start), idx}
    end
  end

  defp skip_whitespace(source, idx) when idx >= byte_size(source), do: idx

  defp skip_whitespace(source, idx) do
    if whitespace?(at(source, idx)), do: skip_whitespace(source, idx + 1), else: idx
  end

  defp starts_with?(source, idx, prefix) do
    prefix_size = byte_size(prefix)
    idx + prefix_size <= byte_size(source) and binary_part(source, idx, prefix_size) == prefix
  end

  defp at(source, idx), do: :binary.at(source, idx)
  defp safe_at(source, idx) when idx < 0 or idx >= byte_size(source), do: nil
  defp safe_at(source, idx), do: at(source, idx)

  defp whitespace?(char), do: char in [?\s, ?\t, ?\n, ?\r]
  defp digit?(char) when is_integer(char), do: char >= ?0 and char <= ?9
  defp digit?(_char), do: false

  defp letter?(char) when is_integer(char),
    do: (char >= ?a and char <= ?z) or (char >= ?A and char <= ?Z)

  defp letter?(_char), do: false
  defp ident_start?(char), do: letter?(char) or char == ?_
  defp ident_char?(char), do: ident_start?(char) or digit?(char) or char in [??, ?!]
  defp tag_name_char?(char), do: letter?(char) or digit?(char) or char in [?:, ?_, ?., ?-]
  defp attr_char_start?(char), do: letter?(char) or char in [?:, ?@, ?_]
  defp attr_char?(char), do: attr_char_start?(char) or digit?(char) or char in [?., ?-]
  defp operator?(char), do: char in [?=, ?+, ?-, ?*, ?/, ?>, ?<, ?!, ?|, ?&]
  defp punct?(char), do: char in [?(, ?), ?[, ?], ?,, ?., ?%]
  defp punct_or_block_char?(char), do: punct?(char) or char in [?{, ?}]
  defp css_ident_start?(char), do: letter?(char) or char in [?_]
  defp css_ident_char?(char), do: css_ident_start?(char) or digit?(char) or char in [?-]
  defp bash_punct?(char), do: char in [?(, ?), ?[, ?], ?{, ?}, ?,, ?., ?%]

  defp hex_char?(char),
    do: digit?(char) or (char >= ?a and char <= ?f) or (char >= ?A and char <= ?F)

  defp hex_color_start?(source, idx) do
    next = safe_at(source, idx + 1)
    hex_char?(next)
  end
end
