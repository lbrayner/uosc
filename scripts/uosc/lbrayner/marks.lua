local concat = table.concat
local control = require("lbrayner/lib/control")
local marks = require("lbrayner/lib/marks")
local playlist_index = require("lbrayner/lib/playlist_index")

local open_marks = create_self_updating_menu_opener({
  title = t('Marks'),
  type = 'marks',
  list_prop = 'user-data/lbrayner/marks/list',
  serializer = function(marks)
    local items = {}

    if not marks then return items end

    local current = mp.get_property(concat({
      "playlist/", mp.get_property("playlist-pos"), "/filename"
    }))

    for index, item in ipairs(marks) do
      items[index] = {
        title = item.filename,
        hint = tostring(item.slot),
        active = item.filename == current,
        value = item,
      }
    end

    return items
  end,
  on_activate = function(event)
    local filename = event.value.filename
    local slot = event.value.slot
    local item = playlist_index.get_extended_playlist_items_by_filename(filename)[1]

    if not item then
      mp.osd_message(concat({ "Mark", slot, "invalid" }, " "))
      return
    end

    control.playlist_jump_to_position(item.pos)
  end,
  on_key = function(event)
    if event.id == 'ctrl+c' and event.selected_item then
      local payload = mp.get_property_native('playlist/' .. (event.selected_item.value - 1) .. '/filename')
      set_clipboard(payload)
    end
  end,
})

mp.add_key_binding("F4", "marks", function()
  marks.load()
  open_marks()
end)
