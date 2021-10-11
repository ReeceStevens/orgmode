local ts_utils = require('nvim-treesitter.ts_utils')
local Motions = {}

local function get_current_section_range()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  while node and node:type() ~= 'section' do
    node = node:parent()
  end
  if not node then
    return
  end
  local start_line, _, end_line, _ = node:range()
  local children = ts_utils.get_named_children(node)
  local start_range = start_line + 1
  local end_range = end_line - 1
  if children[#children]:type() ~= 'section' then
    for _, child in ipairs(children) do
      if child:type() == 'section' then
        local _, _, e, _ = child:range()
        end_range = e
        break
      end
    end
  end

  return start_range, end_range
end

---@param start_range number
---@param end_range number
---@param exclude_stars boolean
local function do_selection(start_range, end_range, exclude_stars)
  local col = 1
  if exclude_stars then
    local _, offset = vim.fn.getline(start_range):find('^%*+%s*')
    col = col + offset
  end
  vim.fn.cursor({ start_range, col })
  local down_motion = ''
  if (end_range - start_range) > 0 then
    down_motion = string.format('%dj', end_range - start_range)
  end
  vim.cmd(string.format('norm!v%s$h', down_motion))
end

local function current_heading(exclude_stars)
  local start_range, end_range = get_current_section_range()
  do_selection(start_range, end_range, exclude_stars)
end

local function current_subtree(exclude_stars)
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  while node and node:type() ~= 'section' do
    node = node:parent()
  end
  if not node then
    return
  end
  local start_range, _, end_range, _ = node:range()
  do_selection(start_range + 1, end_range, exclude_stars)
end

local function current_heading_from_root(exclude_stars)
  local start_range, end_range = get_current_section_range()
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  while node do
    local parent = node:parent()
    if not parent or parent:type() == 'document' then
      break
    end
    node = parent
  end
  local start_line, _, _, _ = node:range()
  start_range = start_line + 1
  do_selection(start_range, end_range, exclude_stars)
end

local function current_subtree_from_root(exclude_stars)
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end
  while node do
    local parent = node:parent()
    if not parent or parent:type() == 'document' then
      break
    end
    node = parent
  end
  local start_range, _, end_range, _ = node:range()
  do_selection(start_range + 1, end_range, exclude_stars)
end

function Motions.inner_heading()
  current_heading(true)
end

function Motions.around_heading()
  current_heading(false)
end

function Motions.inner_subtree()
  current_subtree(true)
end

function Motions.around_subtree()
  current_subtree(false)
end

function Motions.inner_heading_from_root()
  current_heading_from_root(true)
end

function Motions.around_heading_from_root()
  current_heading_from_root(false)
end

function Motions.inner_subtree_from_root()
  current_subtree_from_root(true)
end

function Motions.around_subtree_from_root()
  current_subtree_from_root(false)
end

return Motions
