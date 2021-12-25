local config = require("zk.config")

local M = {}

local function invalid_picker(picker)
  return string.format("Invalid picker '%s'", picker)
end

function M.note_picker(notes, title, picker)
  picker = picker or config.options.picker
  title = title or "Zk Notes"
  if picker == "telescope" then
    require("zk.pickers.telescope").show_note_picker(notes, { prompt_title = title })
  elseif picker == "fzf" then
    require("zk.pickers.fzf").show_note_picker(notes, { "--header=" .. title })
  elseif picker == "select" then
    require("zk.pickers.select").show_note_picker(notes, { prompt = title })
  else
    error(invalid_picker(picker))
  end
end

function M.make_note_picker_api_options(defaults, options, picker)
  picker = picker or config.options.picker

  local function api_options()
    if picker == "telescope" then
      return require("zk.pickers.telescope").note_picker_api_options
    elseif picker == "fzf" then
      return require("zk.pickers.fzf").note_picker_api_options
    elseif picker == "select" then
      return require("zk.pickers.select").note_picker_api_options
    else
      error(invalid_picker(picker))
    end
  end

  return vim.tbl_deep_extend("force", api_options(), defaults or {}, options or {})
end

function M.tag_picker(tags, title, cb, picker)
  picker = picker or config.options.picker
  title = title or "Zk Tags"
  if picker == "telescope" then
    require("zk.pickers.telescope").show_tag_picker(tags, { prompt_title = title }, cb)
  elseif picker == "fzf" then
    require("zk.pickers.fzf").show_tag_picker(tags, { "--header=" .. title }, cb)
  elseif picker == "select" then
    require("zk.pickers.select").show_tag_picker(tags, { prompt = title }, cb)
  else
    invalid_picker(picker)
  end
end

function M.make_tag_picker_api_options(defaults, options, picker)
  picker = picker or config.options.picker

  local function api_options()
    if picker == "telescope" then
      return require("zk.pickers.telescope").tag_picker_api_options
    elseif picker == "fzf" then
      return require("zk.pickers.fzf").tag_picker_api_options
    elseif picker == "select" then
      return require("zk.pickers.select").tag_picker_api_options
    else
      error(invalid_picker(picker))
    end
  end

  return vim.tbl_deep_extend("force", api_options(), defaults or {}, options or {})
end

return M