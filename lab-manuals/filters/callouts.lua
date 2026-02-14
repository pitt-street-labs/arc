-- callouts.lua — Pandoc Lua filter for lab manual callout boxes
-- Converts blockquote markers to LaTeX tcolorbox environments
--
-- Syntax in Markdown:
--   > **See Also:** M1 Section 6 — WireGuard VPN
--   > **STATUS: PLANNED** — Prerequisites: ...
--   > **Warning:** Do not expose this port
--   > **Note:** This requires restart

function BlockQuote(el)
  local first = el.content[1]
  if not first or first.t ~= "Para" then return nil end

  local inlines = first.content
  if #inlines < 1 then return nil end

  -- Extract raw text from the first inline elements
  local text = pandoc.utils.stringify(pandoc.Inlines(inlines))

  -- Determine callout type from prefix
  local env = nil
  local prefix_len = 0

  if text:match("^See Also:") then
    env = "seealsobox"
  elseif text:match("^STATUS: PLANNED") then
    env = "plannedbox"
  elseif text:match("^Warning:") then
    env = "warningbox"
  elseif text:match("^Note:") then
    env = "notebox"
  end

  if env == nil then return nil end

  -- Build LaTeX output: wrap all blockquote content in the environment
  local result = pandoc.List({})
  result:insert(pandoc.RawBlock("latex", "\\begin{" .. env .. "}"))
  for _, block in ipairs(el.content) do
    result:insert(block)
  end
  result:insert(pandoc.RawBlock("latex", "\\end{" .. env .. "}"))

  return result
end
