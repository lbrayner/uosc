local control = require("control")

mp.add_key_binding("g", "playlist_go_to", create_self_updating_menu_opener({
  title = t('Go To'),
  type = 'playlist',
  list_prop = 'playlist',
  serializer = function(playlist)
    local items = {}
    local force_filename = mp.get_property_native('osd-playlist-entry') == 'filename'
    for index, item in ipairs(playlist) do
      items[index] = {
        title = is_protocol(item.filename) and item.filename or serialize_path(item.filename).basename,
        hint = tostring(index),
        active = item.current,
        value = index,
      }
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
