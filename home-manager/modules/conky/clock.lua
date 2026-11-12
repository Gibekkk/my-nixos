-- clock.lua : date + clock, drawn with cairo (design size 1920x1080)
--   left  = date (weekday, day, month, year) + small stats grid
--   right = the clock (hour over minutes, AM/PM)
--   both blocks share the same top line and bottom line
require 'cairo'

------------------------------------------------------------------ settings
local DESIGN_W = 1920

local FONT_NUM   = 'Poppins ExtraLight'
local FONT_LABEL = 'Poppins Light'
local FONT_SMALL = 'Poppins Medium'
local FONT_MONTH = 'Cormorant Garamond Medium'

local WHITE = { 0.90, 0.95, 1.00 }
local BLUE  = { 0.60, 0.80, 0.98 }
local WARM  = { 1.00, 0.74, 0.50 }
local HOT   = { 1.00, 0.50, 0.55 }

local MASTER     = 1.0
local SHOW_STATS = true

local TOP    = 64     -- shared top line (cap tops)
local BOTTOM = 470    -- shared bottom line (year / AM-PM baselines)

local LEFT = {
  x = 84,                          -- left edge of everything on the left
  week_size = 19, week_track = 9,  -- THURSDAY
  day_top = TOP + 34, day_h = 200, day_max_w = 330,
  month_cap_h = 58, month_gap = 26, month_max_w = 330,
  rule_len = 120,
  year_size = 17, year_track = 8,
  stats_top = BOTTOM + 70, stats_col = 170, stats_row = 64,
}
local RIGHT = {
  edge = 1840,                     -- right edge of numerals and labels
  h = 168, gap = 26, max_w = 250,  -- narrow so they clear her hair
  ampm_size = 17, ampm_track = 8,
}

-- ring around the girl (unchanged from clock.lua)
local RING = {
  cx = 1010, cy = 450, r = 600, width = 1.5, alpha = 0.40, soft = 14,
  arcs = { { from = 150, to = 232 }, { from = 298, to = 322 } },
}

------------------------------------------------------------------ helpers
local UTF8 = '[%z\1-\127\194-\244][\128-\191]*'   -- one UTF-8 character
local function rgba(cr, c, a) cairo_set_source_rgba(cr, c[1], c[2], c[3], a * MASTER) end

local function set_font(cr, family, size, italic)
  cairo_select_font_face(cr, family,
    italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, size)
end

local function measure(cr, text)
  local e = cairo_text_extents_t:create(); tolua.takeownership(e)
  cairo_text_extents(cr, text, e)
  return { x_bearing = e.x_bearing, y_bearing = e.y_bearing,
           width = e.width, height = e.height, x_advance = e.x_advance }
end

local function size_for_height(cr, family, italic, sample, target_h)
  set_font(cr, family, 100, italic)
  return 100 * target_h / measure(cr, sample).height
end

local function tracked_width(cr, text, tracking)
  local w = 0
  for ch in text:gmatch(UTF8) do w = w + measure(cr, ch).x_advance + tracking end
  return w - tracking
end

-- letter-spaced text; align 'left' or 'right' (x is the edge)
local function draw_tracked(cr, text, x, y, tracking, align)
  if align == 'right' then x = x - tracked_width(cr, text, tracking) end
  for ch in text:gmatch(UTF8) do
    cairo_move_to(cr, x, y); cairo_show_text(cr, ch)
    x = x + measure(cr, ch).x_advance + tracking
  end
end

-- outlined translucent numerals, ink-aligned to x; returns ink box
local function draw_number(cr, text, x, top, align, target_h, max_w,
                           fill_c, fill_a, stroke_c, stroke_a, lw)
  local size = size_for_height(cr, FONT_NUM, false, '0', target_h)
  set_font(cr, FONT_NUM, size)
  local m = measure(cr, text)
  if m.width > max_w then size = size * max_w / m.width; set_font(cr, FONT_NUM, size); m = measure(cr, text) end
  local px = (align == 'right') and (x - (m.x_bearing + m.width)) or (x - m.x_bearing)
  local base = top - m.y_bearing           -- put the ink top exactly at `top`
  cairo_move_to(cr, px, base)
  cairo_text_path(cr, text)
  rgba(cr, fill_c, fill_a); cairo_fill_preserve(cr)
  rgba(cr, stroke_c, stroke_a); cairo_set_line_width(cr, lw); cairo_stroke(cr)
  return { left = px + m.x_bearing, right = px + m.x_bearing + m.width, bottom = top + m.height }
end

-- short rule that fades out (dir = 1 to the right, -1 to the left)
local function fade_rule(cr, x, y, len, dir)
  local x2 = x + dir * len
  local pat = cairo_pattern_create_linear(x, 0, x2, 0)
  cairo_pattern_add_color_stop_rgba(pat, 0, BLUE[1], BLUE[2], BLUE[3], 0.90 * MASTER)
  cairo_pattern_add_color_stop_rgba(pat, 1, BLUE[1], BLUE[2], BLUE[3], 0.0)
  cairo_set_source(cr, pat); cairo_set_line_width(cr, 1.5)
  cairo_move_to(cr, x, y); cairo_line_to(cr, x2, y); cairo_stroke(cr)
  cairo_pattern_destroy(pat)
end

local function circ_dist(a, b) return math.abs((a - b + 180) % 360 - 180) end
local function ring_alpha(deg)
  deg = deg % 360
  local best = 0
  for _, arc in ipairs(RING.arcs) do
    local v
    if deg >= arc.from and deg <= arc.to then v = 1
    else v = math.max(0, 1 - math.min(circ_dist(deg, arc.from), circ_dist(deg, arc.to)) / RING.soft) end
    v = v * v * (3 - 2 * v)
    if v > best then best = v end
  end
  return RING.alpha * best
end
local function draw_ring(cr)
  cairo_set_line_width(cr, RING.width); cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
  for deg = 0, 359 do
    local a = ring_alpha(deg + 0.5)
    if a > 0.004 then
      rgba(cr, WHITE, a); cairo_new_path(cr)
      cairo_arc(cr, RING.cx, RING.cy, RING.r, math.rad(deg), math.rad(deg + 1.2)); cairo_stroke(cr)
    end
  end
end

------------------------------------------------------------------ stats
local function readline(path)
  local f = io.open(path, 'r'); if not f then return nil end
  local v = f:read('*l'); f:close(); return v
end

-- find the CPU package sensor by name (hwmon numbers change between boots)
local temp_path
local function cpu_temp()
  if not temp_path then
    for i = 0, 15 do
      local dir = '/sys/class/hwmon/hwmon' .. i
      if readline(dir .. '/name') == 'coretemp' then
        temp_path = dir .. '/temp1_input'               -- "Package id 0"
        for j = 1, 8 do
          if (readline(dir .. '/temp' .. j .. '_label') or ''):match('^Package') then
            temp_path = dir .. '/temp' .. j .. '_input'; break
          end
        end
        break
      end
    end
    temp_path = temp_path or '/sys/class/thermal/thermal_zone0/temp'
  end
  local v = tonumber(readline(temp_path) or '')
  return v and math.floor(v / 1000 + 0.5) or nil
end


-- GPU usage: dedicated GPU first, integrated GPU as automatic fallback.
--   dedicated  = boot_vga 0, integrated = boot_vga 1
--   sources    : gpu_busy_percent (amdgpu), RC6 idle residency (i915),
--                actual/max frequency as a rough last resort
-- The dedicated GPU is only read while it is awake (runtime_status
-- "active"), so this never wakes a sleeping dGPU.
local VENDORS = { ['0x8086'] = 'INTEL', ['0x1002'] = 'AMD', ['0x10de'] = 'NVIDIA' }
local gpus     -- { dedicated = {...}, integrated = {...} }

local function uptime_ms()
  return (tonumber((readline('/proc/uptime') or '0'):match('^(%S+)')) or 0) * 1000
end

local function probe_gpus()
  gpus = {}
  for i = 0, 9 do
    local card = '/sys/class/drm/card' .. i
    local dev  = card .. '/device'
    local vendor = readline(dev .. '/vendor')
    if vendor then
      local g = { card = card, dev = dev, name = VENDORS[vendor] or 'GPU' }
      local busy_file = io.open(dev .. '/gpu_busy_percent', 'r')   -- open only: reading could wake a sleeping dGPU
      if busy_file then
        busy_file:close()
        g.method = 'busy'
      elseif readline(card .. '/gt/gt0/rc6_residency_ms') then
        g.method, g.rc6 = 'rc6', card .. '/gt/gt0/rc6_residency_ms'
      elseif readline(card .. '/power/rc6_residency_ms') then
        g.method, g.rc6 = 'rc6', card .. '/power/rc6_residency_ms'
      elseif readline(card .. '/gt_act_freq_mhz') then
        g.method = 'freq'
      end
      if g.method then
        local kind = (readline(dev .. '/boot_vga') == '0') and 'dedicated' or 'integrated'
        gpus[kind] = gpus[kind] or g
      end
    end
  end
end

local function gpu_read(g)
  if not g then return nil end
  if g.method == 'busy' then
    return tonumber(readline(g.dev .. '/gpu_busy_percent') or '')
  elseif g.method == 'rc6' then
    local rc6, now = tonumber(readline(g.rc6) or ''), uptime_ms()
    if not rc6 then return nil end
    local pct
    if g.prev_rc6 and now > g.prev_t then
      pct = 100 * (1 - (rc6 - g.prev_rc6) / (now - g.prev_t))
      pct = math.max(0, math.min(100, math.floor(pct + 0.5)))
    end
    g.prev_rc6, g.prev_t = rc6, now
    return pct or g.last
  elseif g.method == 'freq' then
    local act = tonumber(readline(g.card .. '/gt_act_freq_mhz') or '')
    local min = tonumber(readline(g.card .. '/gt_RPn_freq_mhz') or '') or 0
    local max = tonumber(readline(g.card .. '/gt_RP0_freq_mhz') or '')
    if act and max and max > min then
      return math.floor(100 * math.max(0, act - min) / (max - min) + 0.5)
    end
  end
end

local function gpu_usage()
  if not gpus then probe_gpus() end
  local d = gpus.dedicated
  if d and readline(d.dev .. '/power/runtime_status') ~= 'suspended' then
    local v = gpu_read(d)
    if v then d.last = v; return v, d.name end
  end
  local ig = gpus.integrated
  local v = gpu_read(ig)
  if v then ig.last = v; return v, ig.name end
  return nil, nil
end

local function draw_stat(cr, label, value, x, y, color)
  set_font(cr, FONT_SMALL, 11); rgba(cr, BLUE, 0.70)
  draw_tracked(cr, label, x, y, 3)
  set_font(cr, FONT_LABEL, 19); rgba(cr, color or WHITE, 0.94)
  cairo_move_to(cr, x, y + 25); cairo_show_text(cr, value)
end

------------------------------------------------------------------ main
function conky_main()
  local surface = conky_surface()
  if not surface then return end
  local cr = cairo_create(surface)
  local W = (conky_window and conky_window.width) or DESIGN_W
  local s = W / DESIGN_W
  cairo_scale(cr, s, s)

  local day     = os.date('%d'):gsub('^0', '')
  local month   = os.date('%B')
  local weekday = os.date('%A'):upper()
  local year    = os.date('%Y')
  local hour    = os.date('%I')
  local minute  = os.date('%M')
  local ampm    = os.date('%p')

  draw_ring(cr)

  ---------------------------------------------------------------- LEFT: date
  local L = LEFT
  -- weekday, small tracked caps; its cap top sits on TOP
  set_font(cr, FONT_LABEL, L.week_size); rgba(cr, BLUE, 0.92)
  local wm = measure(cr, 'T')
  draw_tracked(cr, weekday, L.x, TOP - wm.y_bearing, L.week_track)

  -- day number
  local d = draw_number(cr, day, L.x, L.day_top, 'left', L.day_h, L.day_max_w,
                        WHITE, 0.10, WHITE, 0.55, 2.5)

  -- month (italic serif) below the number
  local msize = size_for_height(cr, FONT_MONTH, true, 'N', L.month_cap_h)
  set_font(cr, FONT_MONTH, msize, true)
  local mm = measure(cr, month)
  if mm.width > L.month_max_w then
    msize = msize * L.month_max_w / mm.width; set_font(cr, FONT_MONTH, msize, true); mm = measure(cr, month)
  end
  local month_base = d.bottom + L.month_gap + L.month_cap_h
  rgba(cr, WHITE, 0.96)
  cairo_move_to(cr, L.x - mm.x_bearing, month_base); cairo_show_text(cr, month)

  -- rule + year on the shared bottom line
  set_font(cr, FONT_LABEL, L.year_size); rgba(cr, WHITE, 0.80)
  local ym = measure(cr, '0')
  draw_tracked(cr, year, L.x + L.rule_len + 18, BOTTOM, L.year_track)
  fade_rule(cr, L.x, BOTTOM + ym.y_bearing / 2, L.rule_len, 1)

  ---------------------------------------------------------------- RIGHT: clock
  local R = RIGHT
  draw_number(cr, hour,   R.edge, TOP,                 'right', R.h, R.max_w, WHITE, 0.10, WHITE, 0.55, 2.5)
  draw_number(cr, minute, R.edge, TOP + R.h + R.gap,   'right', R.h, R.max_w, BLUE,  0.22, BLUE,  0.80, 2.5)

  set_font(cr, FONT_LABEL, R.ampm_size); rgba(cr, WHITE, 0.80)
  local aw = tracked_width(cr, ampm, R.ampm_track)
  draw_tracked(cr, ampm, R.edge, BOTTOM, R.ampm_track, 'right')
  fade_rule(cr, R.edge - aw - 18, BOTTOM + ym.y_bearing / 2, L.rule_len, -1)

  ---------------------------------------------------------------- LEFT: stats
  if SHOW_STATS then
    local cpu  = tonumber(conky_parse('${cpu cpu0}')) or 0
    local mem  = tonumber(conky_parse('${memperc}')) or 0
    local swap = tonumber(conky_parse('${swapperc}'))
    local bat  = tonumber(conky_parse('${battery_percent BAT0}')) or 0
    local t    = cpu_temp()
    local tcol = (t and t >= 90) and HOT or (t and t >= 75) and WARM or WHITE
    local g, gname = gpu_usage()
    local x1, x2 = L.x, L.x + L.stats_col
    local y0, dy = L.stats_top, L.stats_row
    draw_stat(cr, 'CPU',  cpu .. '%',                      x1, y0)
    draw_stat(cr, 'TEMP', t and (t .. '°C') or '—',        x2, y0, tcol)
    draw_stat(cr, 'RAM',  mem .. '%',                      x1, y0 + dy)
    draw_stat(cr, 'SWAP', swap and (swap .. '%') or '—',   x2, y0 + dy)
    draw_stat(cr, gname and ('GPU · ' .. gname) or 'GPU',
                  g and (g .. '%') or '—',                 x1, y0 + 2 * dy)
    draw_stat(cr, 'BAT',  bat .. '%',                      x2, y0 + 2 * dy)
  end

  cairo_destroy(cr)
end
