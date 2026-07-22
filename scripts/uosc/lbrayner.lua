local home = os.getenv("MPV_CONFIG_HOME")

if not home or home == "" then
  print("MPV_CONFIG_HOME is required.")
  return
end

local concat = table.concat

package.path = concat({ package.path, concat({ home, "lib/?.lua" }, "/") }, ";")

require("lbrayner.playlist_go_to")
