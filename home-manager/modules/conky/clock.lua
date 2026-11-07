-- clock.lua : layout drawn with cairo (design size 1920x1080, scaled to the window)
require 'cairo'

------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------
local DESIGN_W = 1920

-- fonts (check names with: fc-list | grep -i -E "poppins|cormorant")
local FONT_NUM   = 'Poppins ExtraLight'    -- big numerals
local FONT_LABEL = 'Poppins Light'         -- weekday + time
local FONT_MONTH = 'Cormorant Garamond Medium' -- italic serif month

-- colours
local WHITE = { 0.90, 0.95, 1.00 }
local BLUE  = { 0.60, 0.80, 0.98 }

-- overall opacity multiplier (1.0 = as designed)
local MASTER = 1.0

-- ring around the girl. Angles in degrees, 0 = right, 90 = down, 180 = left,
-- 270 = up. In the reference the ring sits BEHIND her, but conky draws on top of
-- the video, so the ring is only drawn on the arcs that are free of her (hair,
-- hand, shoulders) and fades out smoothly at the ends of each arc.
local RING = {
  cx = 1010, cy = 450, r = 600,
  width = 1.5,
  alpha = 0.40,                -- opacity on the visible arcs
  soft = 14,                   -- degrees of fade at the ends of each arc
  arcs = {
    { from = 150, to = 232 },  -- left side (top-left -> down to the hand)
    { from = 298, to = 322 },  -- small piece at the top right
  },
}

-- layout (design pixels)
local LEFT = {
  day_x = 65,  day_top = 40,  day_h = 255, day_max_w = 380,
  month_x = 97, month_base = 283, month_cap_h = 66, month_max_w = 340,
  week_x = 75, week_y = 482, week_size = 22, week_track = 16,
  time_x = 100, time_base = 355, time_size = 33, time_track = 4,
  line_x = 100, line_y = 378, line_len = 105,
}
local RIGHT = {
  edge_x = 1896,           -- right edge of the numerals
  top = 40, h = 180, gap = 30, max_w = 255,   -- kept narrow so they clear her hair
}

------------------------------------------------------------------
-- helpers
------------------------------------------------------------------
local function rgba(cr, c, a)
  cairo_set_source_rgba(cr, c[1], c[2], c[3], a * MASTER)
end

local function set_font(cr, family, size, italic)
  cairo_select_font_face(cr, family,
    italic and CAIRO_FONT_SLANT_ITALIC or CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, size)
end

local function measure(cr, text)
  local e = cairo_text_extents_t:create()
  tolua.takeownership(e)
  cairo_text_extents(cr, text, e)
  return {
    x_bearing = e.x_bearing, y_bearing = e.y_bearing,
    width = e.width, height = e.height, x_advance = e.x_advance,
  }
end

-- font size that gives the glyph `sample` an ink height of target_h
local function size_for_height(cr, family, italic, sample, target_h)
  set_font(cr, family, 100, italic)
  return 100 * target_h / measure(cr, sample).height
end

-- outlined, translucent numerals aligned by their ink edge
local function draw_number(cr, text, x, baseline, align, target_h, max_w,
                           fill_c, fill_a, stroke_c, stroke_a, lw)
  local size = size_for_height(cr, FONT_NUM, false, '0', target_h)
  set_font(cr, FONT_NUM, size)
  local m = measure(cr, text)
  if m.width > max_w then
    size = size * max_w / m.width
    set_font(cr, FONT_NUM, size)
    m = measure(cr, text)
  end
  local px
  if align == 'right' then
    px = x - (m.x_bearing + m.width)
  else
    px = x - m.x_bearing
  end
  cairo_move_to(cr, px, baseline)
  cairo_text_path(cr, text)
  rgba(cr, fill_c, fill_a)
  cairo_fill_preserve(cr)
  rgba(cr, stroke_c, stroke_a)
  cairo_set_line_width(cr, lw)
  cairo_stroke(cr)
end

-- letter-spaced text (ASCII), starting at x,y (baseline)
local function draw_tracked(cr, text, x, y, tracking)
  for ch in text:gmatch('.') do
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, ch)
    x = x + measure(cr, ch).x_advance + tracking
  end
end

local function circ_dist(a, b)
  return math.abs((a - b + 180) % 360 - 180)
end

local function ring_alpha(deg)
  deg = deg % 360
  local best = 0
  for _, arc in ipairs(RING.arcs) do
    local v
    if deg >= arc.from and deg <= arc.to then
      v = 1
    else
      local d = math.min(circ_dist(deg, arc.from), circ_dist(deg, arc.to))
      v = math.max(0, 1 - d / RING.soft)
    end
    v = v * v * (3 - 2 * v)          -- smoothstep
    if v > best then best = v end
  end
  return RING.alpha * best
end

local function draw_ring(cr)
  cairo_set_line_width(cr, RING.width)
  cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
  for deg = 0, 359 do
    local a = ring_alpha(deg + 0.5)
    if a > 0.004 then
      rgba(cr, WHITE, a)
      cairo_new_path(cr)
      cairo_arc(cr, RING.cx, RING.cy, RING.r,
        math.rad(deg), math.rad(deg + 1.2))
      cairo_stroke(cr)
    end
  end
end

------------------------------------------------------------------
-- main draw hook
------------------------------------------------------------------
function conky_main()
  local surface = conky_surface()
  if not surface then return end
  local cr = cairo_create(surface)

  local W = (conky_window and conky_window.width) or DESIGN_W
  local s = W / DESIGN_W
  cairo_scale(cr, s, s)

  local day     = os.date('%d')
  local month   = os.date('%B')
  local weekday = os.date('%A'):upper()
  local hour    = os.date('%I')
  local minute  = os.date('%M')
  local clock   = (os.date('%I:%M %p'):gsub('^0', ''))

  -- ring first, so everything else sits on top of it
  draw_ring(cr)

  -- LEFT: day number (outlined, translucent)
  draw_number(cr, day, LEFT.day_x, LEFT.day_top + LEFT.day_h, 'left',
    LEFT.day_h, LEFT.day_max_w, WHITE, 0.10, WHITE, 0.55, 2.5)

  -- LEFT: month, italic serif, overlapping the bottom of the day number
  do
    local size = size_for_height(cr, FONT_MONTH, true, 'N', LEFT.month_cap_h)
    set_font(cr, FONT_MONTH, size, true)
    local m = measure(cr, month)
    if m.width > LEFT.month_max_w then
      size = size * LEFT.month_max_w / m.width
      set_font(cr, FONT_MONTH, size, true)
      m = measure(cr, month)
    end
    rgba(cr, WHITE, 0.96)
    cairo_move_to(cr, LEFT.month_x - m.x_bearing, LEFT.month_base)
    cairo_show_text(cr, month)
  end

  -- LEFT: weekday, rotated to read bottom -> top
  cairo_save(cr)
  cairo_translate(cr, LEFT.week_x, LEFT.week_y)
  cairo_rotate(cr, -math.pi / 2)
  set_font(cr, FONT_LABEL, LEFT.week_size)
  rgba(cr, BLUE, 0.90)
  draw_tracked(cr, weekday, 0, 0, LEFT.week_track)
  cairo_restore(cr)

  -- LEFT: time + small rule
  set_font(cr, FONT_LABEL, LEFT.time_size)
  rgba(cr, WHITE, 0.96)
  draw_tracked(cr, clock, LEFT.time_x, LEFT.time_base, LEFT.time_track)

  local pat = cairo_pattern_create_linear(LEFT.line_x, 0, LEFT.line_x + LEFT.line_len, 0)
  cairo_pattern_add_color_stop_rgba(pat, 0, BLUE[1], BLUE[2], BLUE[3], 0.90 * MASTER)
  cairo_pattern_add_color_stop_rgba(pat, 1, BLUE[1], BLUE[2], BLUE[3], 0.0)
  cairo_set_source(cr, pat)
  cairo_set_line_width(cr, 1.5)
  cairo_move_to(cr, LEFT.line_x, LEFT.line_y)
  cairo_line_to(cr, LEFT.line_x + LEFT.line_len, LEFT.line_y)
  cairo_stroke(cr)
  cairo_pattern_destroy(pat)

  -- RIGHT: hour over minutes, right-aligned, outlined
  local base1 = RIGHT.top + RIGHT.h
  local base2 = base1 + RIGHT.gap + RIGHT.h
  draw_number(cr, hour, RIGHT.edge_x, base1, 'right', RIGHT.h, RIGHT.max_w,
    WHITE, 0.10, WHITE, 0.50, 2)
  draw_number(cr, minute, RIGHT.edge_x, base2, 'right', RIGHT.h, RIGHT.max_w,
    BLUE, 0.22, BLUE, 0.75, 2)

  cairo_destroy(cr)
end