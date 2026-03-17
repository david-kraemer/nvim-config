--- Hebrew calendar integration via the hebcal CLI.
--- Provides daily Jewish date, learning schedules, and zmanim.
--- Location defaults to Pittsburgh; override with $HEBCAL_CITY.

local M = {}

--- Curated zmanim in halachic order.
---@type {[1]: string, [2]: string}[]
M.zman_spec = {
  { 'Sunrise', 'Neitz' },
  { 'Kriat Shema, sof zeman (GRA)', 'Shema' },
  { 'Tefilah, sof zeman (GRA)', 'Tefila' },
  { 'Chatzot hayom', 'Chatzot' },
  { 'Mincha Gedolah', 'Mincha' },
  { 'Plag HaMincha', 'Plag' },
  { 'Candle lighting', 'Candles' },
  { 'Sunset', 'Shkiah' },
  { 'Tzeit HaKochavim', 'Tzeit' },
  { 'Havdalah (72 min)', 'Havdala' },
}

-- ============================================================================
-- Private helpers
-- ============================================================================

---@param t24 string HH:MM in 24h (zero-padded)
---@return string 12h display like "7:28a"
local function fmt12(t24)
  local h, m = t24:match '(%d+):(%d+)'
  h = tonumber(h)
  if h == 0 then
    return '12:' .. m .. 'a'
  elseif h < 12 then
    return h .. ':' .. m .. 'a'
  elseif h == 12 then
    return '12:' .. m .. 'p'
  else
    return (h - 12) .. ':' .. m .. 'p'
  end
end

--- Single shell invocation for all calendar data.
--- Table-form vim.fn.system bypasses shell — no injection risk from city.
---@param city string
---@return string|nil raw output, or nil on error
local function run_hebcal(city)
  local out = vim.fn.system {
    'hebcal',
    '-t',
    '-S',
    '-d',
    '--nach-yomi',
    '--mishna-yomi',
    '-Z',
    '-c',
    '-C',
    city,
    '-E',
  }
  if vim.v.shell_error ~= 0 then
    vim.notify('hebcal: exit ' .. vim.v.shell_error, vim.log.levels.WARN)
    return nil
  end
  return out
end

--- Parse hebcal output into structured data.
--- Classification order: zmanim first (most lines), then parsha, date, mishna, nach.
---@param raw string hebcal -t output
---@param now string HH:MM current time (zero-padded)
---@return hebcal.Today
local function parse_output(raw, now)
  local heb_date, parsha, nach, mishna = '', '', '', ''
  local by_name = {}

  for line in raw:gmatch '[^\n]+' do
    local content = line:match '^%S+%s+(.+)$'
    if not content then
      goto continue
    end

    -- Zmanim: "Label: HH:MM" (most lines match this)
    local zman_name, zman_time = content:match '^(.-):%s+(%d%d:%d%d)$'
    if zman_name and zman_time then
      by_name[zman_name] = zman_time
    elseif content:match '^Parashat%s+' then
      parsha = content:gsub('^Parashat%s+', '')
    elseif content:match '^%d+%a*%s+of%s+' then
      heb_date = content
    elseif content:match '%d+:%d+' then
      -- Chapter:verse pattern — mishna yomit (e.g. "Meilah 3:6-7")
      mishna = content
    else
      -- Remaining: nach yomi (e.g. "Judges 10")
      nach = content
    end

    ::continue::
  end

  local zmanim = {}
  for _, spec in ipairs(M.zman_spec) do
    local t24 = by_name[spec[1]]
    if t24 then
      table.insert(zmanim, {
        name = spec[1],
        label = spec[2],
        time24 = t24,
        time12 = fmt12(t24),
        -- String comparison valid: both are zero-padded HH:MM
        -- (hebcal -E guarantees leading zeros; os.date '%H:%M' likewise)
        passed = t24 <= now,
        is_candle = spec[1] == 'Candle lighting',
      })
    end
  end

  return { heb_date = heb_date, parsha = parsha, nach = nach, mishna = mishna, zmanim = zmanim }
end

--- Join parsha and daily learning into a display string.
--- Used by both dashboard_sections() and lines().
---@param day hebcal.Today
---@return string possibly empty
local function learning_text(day)
  local parts = {}
  if day.parsha ~= '' then
    parts[#parts + 1] = day.parsha
  end
  if day.nach ~= '' then
    parts[#parts + 1] = day.nach
  end
  if day.mishna ~= '' then
    parts[#parts + 1] = day.mishna
  end
  return table.concat(parts, '  ·  ')
end

-- ============================================================================
-- Public API
-- ============================================================================

local EMPTY = { heb_date = '', parsha = '', nach = '', mishna = '', zmanim = {} }

---@class hebcal.Today
---@field heb_date string e.g. "28th of Adar, 5786"
---@field parsha string e.g. "Vayikra" or ""
---@field nach string e.g. "Judges 10" or ""
---@field mishna string e.g. "Meilah 3:6-7" or ""
---@field zmanim {name: string, label: string, time24: string, time12: string, passed: boolean, is_candle: boolean}[]

--- Fetch today's Hebrew calendar data via a single hebcal invocation.
---@return hebcal.Today
function M.today()
  local city = vim.env.HEBCAL_CITY or 'Pittsburgh'
  local now = os.date '%H:%M'

  local raw = run_hebcal(city)
  if not raw then
    return EMPTY
  end

  return parse_output(raw, now)
end

--- Build snacks.nvim dashboard sections from today's data.
---@return snacks.dashboard.Section[]
function M.dashboard_sections()
  local day = M.today()

  -- Partition zmanim
  local passed, upcoming, candle_text = {}, {}, nil
  for _, z in ipairs(day.zmanim) do
    local entry = z.label .. ' ' .. z.time12
    if z.is_candle then
      candle_text = '🕯  ' .. entry
    elseif z.passed then
      table.insert(passed, entry)
    else
      table.insert(upcoming, entry)
    end
  end

  -- Format into rows of 3
  local function rows(items)
    local out = {}
    for i = 1, #items, 3 do
      local chunk = {}
      for j = i, math.min(i + 2, #items) do
        table.insert(chunk, items[j])
      end
      table.insert(out, table.concat(chunk, '    '))
    end
    return out
  end

  local sections = {}
  for _, row in ipairs(rows(passed)) do
    table.insert(sections, { text = { row, hl = 'Comment' }, align = 'center' })
  end
  if candle_text then
    table.insert(sections, { text = { candle_text, hl = 'DiagnosticWarn' }, align = 'center' })
  end
  for _, row in ipairs(rows(upcoming)) do
    table.insert(sections, { text = { row, hl = 'SnacksDashboardDesc' }, align = 'center' })
  end

  local learning = learning_text(day)
  local result = {
    { padding = 2 },
    { text = { day.heb_date, hl = 'SnacksDashboardHeader' }, align = 'center' },
  }
  if learning ~= '' then
    table.insert(result, { text = { learning, hl = 'SnacksDashboardDesc' }, align = 'center', padding = 1 })
  end
  for _, s in ipairs(sections) do
    table.insert(result, s)
  end
  return result
end

--- Structured lines and highlights for the floating window.
---@return {text: string, hl: string}[]
function M.lines()
  local day = M.today()
  local out = {}

  table.insert(out, { text = day.heb_date, hl = 'DiagnosticInfo' })

  local learning = learning_text(day)
  if learning ~= '' then
    table.insert(out, { text = learning, hl = 'NormalFloat' })
  end

  table.insert(out, { text = '', hl = 'NormalFloat' })
  for _, z in ipairs(day.zmanim) do
    local prefix = z.is_candle and '🕯 ' or '  '
    local text = prefix .. z.label .. '  ' .. z.time12
    local hl = z.passed and 'Comment' or z.is_candle and 'DiagnosticWarn' or 'NormalFloat'
    table.insert(out, { text = text, hl = hl })
  end
  return out
end

--- Open a floating window with today's hebcal info.
function M.float()
  local lines = M.lines()

  -- Compute content width
  local width = 0
  local texts = {}
  for _, l in ipairs(lines) do
    local display_width = vim.fn.strdisplaywidth(l.text)
    if display_width > width then
      width = display_width
    end
    table.insert(texts, l.text)
  end
  width = width + 4

  -- Center each line within the window
  local centered = {}
  for _, t in ipairs(texts) do
    local pad = math.floor((width - vim.fn.strdisplaywidth(t)) / 2)
    table.insert(centered, string.rep(' ', pad) .. t)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, centered)

  for i, l in ipairs(lines) do
    vim.api.nvim_buf_add_highlight(buf, -1, l.hl, i - 1, 0, -1)
  end

  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' hebcal ',
    title_pos = 'center',
  })

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set('n', 'q', close, { buffer = buf, nowait = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, nowait = true })
  vim.api.nvim_create_autocmd('BufLeave', { buffer = buf, once = true, callback = close })
end

return M
