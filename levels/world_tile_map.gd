extends TileMap

var stats = Stats
var current_planet_index = stats.save_data.run_data.current_planet["planet_index"]

func destroy(pos):
	print(pos)
	stats.save_data["run_data"]["zones"][current_planet_index.y][current_planet_index.x]["planets"][current_planet_index.z]["persistant_data"]["destroyed_tiles"].append(pos)
	set_cells_terrain_connect(0,[local_to_map(pos)],0,-1)
	
