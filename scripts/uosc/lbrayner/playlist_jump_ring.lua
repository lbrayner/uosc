local concat = table.concat
local control = require("lbrayner/lib/control")
local playlist_index = require("lbrayner/lib/playlist_index")
local playlist_jump_ring = require("lbrayner/lib/playlist_jump_ring")

local open_jump_ring = create_self_updating_menu_opener({
  title = t('Playlist Jump Ring'),
  type = 'playlist_jump_ring',
  list_prop = 'user-data/lbrayner/playlist_jump_ring/playlist_jump_ring',
  serializer = function(jump_ring)
    local items = {}

    if not jump_ring then return items end

    local current = mp.get_property(concat({
      "playlist/", mp.get_property("playlist-pos"), "/filename"
    }))

    for index, filename in ipairs(jump_ring) do
      table.insert(items, {
        title = filename,
        hint = tostring(index),
        value = {
          filename = filename,
          index = index,
        },
        active = filename == current,
      })
    end
    return items
  end,
  on_activate = function(event)
    local index = event.value.index
    local filename = event.value.filename
    local item = playlist_index.get_extended_playlist_items_by_filename(filename)[1]

    if not item then
      mp.osd_message(concat({ "Playlist Jump Ring position", index, "invalid" }, " "))
      return
    end

    control.playlist_jump_to_position(item.pos)
  end,
  on_key = function(event)
    if event.id == 'ctrl+c' and event.selected_item then
      set_clipboard(event.selected_item.value.filename)
    end
  end,
  on_move = function(event)
    local from, to = event.from_index, event.to_index
    mp.commandv('playlist-move', tostring(from - 1), tostring(to - (to > from and 0 or 1)))
  end,
  on_remove = function(event) mp.commandv('playlist-remove', tostring(event.value - 1)) end,
})

mp.add_key_binding("F5", "playlist_jump_ring", function()
  playlist_jump_ring.load()
  open_jump_ring()
end)
