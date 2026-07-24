local control = require("lbrayner/lib/control")
local EXTENDED_PLAYLIST_ITEMS_BY_FILENAME = (
  "user-data/lbrayner/playlist_index/extended_playlist_items_by_filename"
)

mp.add_key_binding("F5", "playlist_jump_ring", create_self_updating_menu_opener({
  title = t('Playlist Jump Ring'),
  type = 'playlist_jump_ring',
  list_prop = 'user-data/lbrayner/playlist_index/extended_playlist_items_by_filename',
  serializer = function(playlist)
    local items = {}
    require("mp.msg").info("helo from uosc")

    print("playlist", playlist)
    if not playlist then return items end
    print("Hello")

    local force_filename = mp.get_property_native('osd-playlist-entry') == 'filename'
    for _, is in pairs(playlist) do
      local i = is[1]

      table.insert(items, {
        title = is_protocol(i.filename) and i.filename or serialize_path(i.filename).basename,
        hint = tostring(i.pos),
        active = i.current,
        value = i.pos,
      })
    end
    return items
  end,
  on_activate = function(event)
    local count = mp.get_property_native("playlist-count")

    if count == 1 then return end

    control.previous_position_save()
    mp.commandv('set', 'playlist-pos-1', tostring(event.value))
  end,
  on_paste = function(event) mp.commandv('loadfile', tostring(event.value), 'append') end,
  on_key = function(event)
    if event.id == 'ctrl+c' and event.selected_item then
      local payload = mp.get_property_native('playlist/' .. (event.selected_item.value - 1) .. '/filename')
      set_clipboard(payload)
    end
  end,
  on_move = function(event)
    local from, to = event.from_index, event.to_index
    mp.commandv('playlist-move', tostring(from - 1), tostring(to - (to > from and 0 or 1)))
  end,
  on_remove = function(event) mp.commandv('playlist-remove', tostring(event.value - 1)) end,
}))
