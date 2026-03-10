(() => {
  const keywordPattern = /^(true|false|nil|do|end|fn|if|else|case|when|with|for|in)$/
  const elixirKeywordPattern =
    /^(true|false|nil|do|end|fn|if|else|case|when|with|for|in|def|defp|defmodule|use|alias|import|require|quote|unquote|try|catch|rescue|receive|after|cond)$/
  const cssKeywordPattern =
    /^(auto|inherit|initial|unset|none|block|inline|flex|grid|relative|absolute|fixed|sticky|rem|em|vh|vw|min|max)$/
  const qs = (selector) => Array.from(document.querySelectorAll(selector))
  const escapeHtml = (value) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;")

  const readBalanced = (source, start, openChar, closeChar) => {
    let depth = 0
    let i = start
    let quote = null

    while (i < source.length) {
      const char = source[i]

      if (quote) {
        if (char === "\\") {
          i += 2
          continue
        }

        if (char === quote) quote = null
        i += 1
        continue
      }

      if (char === '"' || char === "'") {
        quote = char
        i += 1
        continue
      }

      if (char === openChar) depth += 1
      if (char === closeChar) {
        depth -= 1
        if (depth === 0) {
          return { chunk: source.slice(start, i + 1), end: i + 1 }
        }
      }

      i += 1
    }

    return { chunk: source.slice(start), end: source.length }
  }

  const highlightExpression = (expr) => {
    let out = ""
    let i = 0

    while (i < expr.length) {
      const char = expr[i]

      if (char === "{" || char === "}") {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      if (char === '"' || char === "'") {
        let j = i + 1
        while (j < expr.length) {
          if (expr[j] === "\\") {
            j += 2
            continue
          }
          if (expr[j] === char) {
            j += 1
            break
          }
          j += 1
        }

        out += `<span class="tok-string">${escapeHtml(expr.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === ":" && /[A-Za-z_]/.test(expr[i + 1] || "")) {
        let j = i + 2
        while (j < expr.length && /[A-Za-z0-9_?!]/.test(expr[j])) j += 1
        out += `<span class="tok-atom">${escapeHtml(expr.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[0-9]/.test(char)) {
        let j = i + 1
        while (j < expr.length && /[0-9._]/.test(expr[j])) j += 1
        out += `<span class="tok-number">${escapeHtml(expr.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[A-Za-z_]/.test(char)) {
        let j = i + 1
        while (j < expr.length && /[A-Za-z0-9_?!]/.test(expr[j])) j += 1
        const word = expr.slice(i, j)
        const klass = keywordPattern.test(word) ? "tok-keyword" : "tok-ident"
        out += `<span class="${klass}">${escapeHtml(word)}</span>`
        i = j
        continue
      }

      if (/[=+\-*/<>!|&]/.test(char)) {
        let j = i + 1
        while (j < expr.length && /[=+\-*/<>!|&]/.test(expr[j])) j += 1
        out += `<span class="tok-operator">${escapeHtml(expr.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[()[\],.%]/.test(char)) {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      out += escapeHtml(char)
      i += 1
    }

    return `<span class="tok-expr">${out}</span>`
  }

  const highlightTag = (tag) => {
    if (tag.startsWith("<!--")) {
      return `<span class="tok-comment">${escapeHtml(tag)}</span>`
    }

    const closing = tag.startsWith("</")
    const selfClosing = tag.endsWith("/>")
    const closeToken = selfClosing ? "/>" : ">"
    let cursor = closing ? 2 : 1
    let out = `<span class="tok-punct">${closing ? "&lt;/" : "&lt;"}</span>`

    let nameEnd = cursor
    while (nameEnd < tag.length && /[:A-Za-z0-9_.-]/.test(tag[nameEnd])) nameEnd += 1
    const tagName = tag.slice(cursor, nameEnd)
    out += `<span class="tok-tag">${escapeHtml(tagName)}</span>`
    cursor = nameEnd

    while (cursor < tag.length - closeToken.length) {
      const char = tag[cursor]

      if (/\s/.test(char)) {
        out += char
        cursor += 1
        continue
      }

      if (char === "{") {
        const { chunk, end } = readBalanced(tag, cursor, "{", "}")
        out += highlightExpression(chunk)
        cursor = end
        continue
      }

      if (char === '"' || char === "'") {
        let j = cursor + 1
        while (j < tag.length) {
          if (tag[j] === "\\") {
            j += 2
            continue
          }
          if (tag[j] === char) {
            j += 1
            break
          }
          j += 1
        }
        out += `<span class="tok-string">${escapeHtml(tag.slice(cursor, j))}</span>`
        cursor = j
        continue
      }

      if (char === "=") {
        out += `<span class="tok-operator">${escapeHtml(char)}</span>`
        cursor += 1
        continue
      }

      if (char === "/") {
        out += `<span class="tok-punct">/</span>`
        cursor += 1
        continue
      }

      if (/[@:A-Za-z_]/.test(char)) {
        let j = cursor + 1
        while (j < tag.length && /[@:A-Za-z0-9_.-]/.test(tag[j])) j += 1
        out += `<span class="tok-attr">${escapeHtml(tag.slice(cursor, j))}</span>`
        cursor = j
        continue
      }

      out += escapeHtml(char)
      cursor += 1
    }

    out += `<span class="tok-punct">${closeToken === "/>" ? "/&gt;" : "&gt;"}</span>`
    return out
  }

  const highlightHeex = (source) => {
    let out = ""
    let i = 0

    while (i < source.length) {
      if (source.startsWith("<!--", i)) {
        const end = source.indexOf("-->", i + 4)
        const chunk = end === -1 ? source.slice(i) : source.slice(i, end + 3)
        out += `<span class="tok-comment">${escapeHtml(chunk)}</span>`
        i += chunk.length
        continue
      }

      if (source[i] === "<") {
        const tagEnd = source.indexOf(">", i + 1)
        if (tagEnd === -1) {
          out += escapeHtml(source.slice(i))
          break
        }

        const tag = source.slice(i, tagEnd + 1)
        out += highlightTag(tag)
        i = tagEnd + 1
        continue
      }

      if (source[i] === "{") {
        const { chunk, end } = readBalanced(source, i, "{", "}")
        out += highlightExpression(chunk)
        i = end
        continue
      }

      let j = i
      while (j < source.length && source[j] !== "<" && source[j] !== "{") j += 1
      out += `<span class="tok-text">${escapeHtml(source.slice(i, j))}</span>`
      i = j
    }

    return out
  }

  const highlightElixir = (source) => {
    let out = ""
    let i = 0

    while (i < source.length) {
      const char = source[i]

      if (char === "#") {
        let j = i + 1
        while (j < source.length && source[j] !== "\n") j += 1
        out += `<span class="tok-comment">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === '"' || char === "'") {
        let j = i + 1
        while (j < source.length) {
          if (source[j] === "\\") {
            j += 2
            continue
          }
          if (source[j] === char) {
            j += 1
            break
          }
          j += 1
        }
        out += `<span class="tok-string">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === ":" && /[A-Za-z_]/.test(source[i + 1] || "")) {
        let j = i + 2
        while (j < source.length && /[A-Za-z0-9_?!]/.test(source[j])) j += 1
        out += `<span class="tok-atom">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[0-9]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[0-9._]/.test(source[j])) j += 1
        out += `<span class="tok-number">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[A-Z]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[A-Za-z0-9_.]/.test(source[j])) j += 1
        out += `<span class="tok-tag">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[a-z_]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[A-Za-z0-9_?!]/.test(source[j])) j += 1
        const word = source.slice(i, j)
        const klass = elixirKeywordPattern.test(word) ? "tok-keyword" : "tok-ident"
        out += `<span class="${klass}">${escapeHtml(word)}</span>`
        i = j
        continue
      }

      if (/[=+\-*/<>!|&]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[=+\-*/<>!|&]/.test(source[j])) j += 1
        out += `<span class="tok-operator">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[()[\]{}.,%]/.test(char)) {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      out += escapeHtml(char)
      i += 1
    }

    return out
  }

  const highlightCss = (source) => {
    let out = ""
    let i = 0

    while (i < source.length) {
      if (source.startsWith("/*", i)) {
        const end = source.indexOf("*/", i + 2)
        const j = end === -1 ? source.length : end + 2
        out += `<span class="tok-comment">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      const char = source[i]

      if (char === '"' || char === "'") {
        let j = i + 1
        while (j < source.length) {
          if (source[j] === "\\") {
            j += 2
            continue
          }
          if (source[j] === char) {
            j += 1
            break
          }
          j += 1
        }
        out += `<span class="tok-string">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === "-" && source[i + 1] === "-") {
        let j = i + 2
        while (j < source.length && /[A-Za-z0-9-]/.test(source[j])) j += 1
        out += `<span class="tok-attr">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[0-9]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[0-9.%a-zA-Z_-]/.test(source[j])) j += 1
        out += `<span class="tok-number">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[A-Za-z@.#]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[A-Za-z0-9@._#-]/.test(source[j])) j += 1
        const word = source.slice(i, j)
        const next = source[j] || ""
        const klass = next === ":" ? "tok-attr" : cssKeywordPattern.test(word) ? "tok-keyword" : "tok-ident"
        out += `<span class="${klass}">${escapeHtml(word)}</span>`
        i = j
        continue
      }

      if (/[{}():;,]/.test(char)) {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      out += escapeHtml(char)
      i += 1
    }

    return out
  }

  const highlightBash = (source) => {
    let out = ""
    let i = 0

    while (i < source.length) {
      const char = source[i]

      if (char === "#") {
        let j = i + 1
        while (j < source.length && source[j] !== "\n") j += 1
        out += `<span class="tok-comment">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === '"' || char === "'") {
        let j = i + 1
        while (j < source.length) {
          if (source[j] === "\\") {
            j += 2
            continue
          }
          if (source[j] === char) {
            j += 1
            break
          }
          j += 1
        }
        out += `<span class="tok-string">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === "$" && /[A-Za-z_{]/.test(source[i + 1] || "")) {
        let j = i + 1
        if (source[j] === "{") {
          j += 1
          while (j < source.length && source[j] !== "}") j += 1
          if (source[j] === "}") j += 1
        } else {
          while (j < source.length && /[A-Za-z0-9_]/.test(source[j])) j += 1
        }
        out += `<span class="tok-atom">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (char === "-" && source[i + 1] === "-") {
        let j = i + 2
        while (j < source.length && /[A-Za-z0-9-]/.test(source[j])) j += 1
        out += `<span class="tok-attr">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[0-9]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[0-9._]/.test(source[j])) j += 1
        out += `<span class="tok-number">${escapeHtml(source.slice(i, j))}</span>`
        i = j
        continue
      }

      if (/[A-Za-z_./]/.test(char)) {
        let j = i + 1
        while (j < source.length && /[A-Za-z0-9_./:-]/.test(source[j])) j += 1
        const word = source.slice(i, j)
        const klass = /^(mix|cd|npm|pnpm|yarn|bun)$/.test(word) ? "tok-keyword" : "tok-ident"
        out += `<span class="${klass}">${escapeHtml(word)}</span>`
        i = j
        continue
      }

      if (/[|&=]/.test(char)) {
        out += `<span class="tok-operator">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      if (/[()[\]{}]/.test(char)) {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`
        i += 1
        continue
      }

      out += escapeHtml(char)
      i += 1
    }

    return out
  }

  const blockLanguage = (block, source) => {
    const classes = Array.from(block.classList)
    const explicit = classes.find((klass) => klass.startsWith("language-"))

    if (explicit) return explicit.replace("language-", "")
    if (source.includes("<.") || source.includes("</.") || source.includes("<:") || source.includes("</:")) return "heex"

    return "plain"
  }

  const highlightCodeBlocks = () => {
    qs("pre code").forEach((block) => {
      if (block.dataset.highlighted === "true") return

      const source = block.textContent || ""
      if (source.trim() === "") return

      switch (blockLanguage(block, source)) {
        case "heex":
          block.innerHTML = highlightHeex(source)
          break
        case "elixir":
          block.innerHTML = highlightElixir(source)
          break
        case "css":
          block.innerHTML = highlightCss(source)
          break
        case "bash":
        case "shell":
        case "sh":
          block.innerHTML = highlightBash(source)
          break
        default:
          block.innerHTML = escapeHtml(source)
      }

      block.classList.add("code-highlight")
      block.dataset.highlighted = "true"
    })
  }

  window.CinderUISiteShared = {
    escapeHtml,
    highlightCodeBlocks,
  }
})()
