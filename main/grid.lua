require("main.tile")
require("libraries.grid.grid")

local Base = require("libraries.knife.base")
local TileType = require("main.tiletype")

Grid = Base:extend()

ref = nil

math.randomseed(os.time())
math.random(); math.random(); math.random()

function Grid:constructor(width, height, tile_size, tile_map, tile_map_layer, maze_width, maze_height)

	ref = self

	self.maze_width = maze_width
	self.maze_height = maze_height
	self.width = width + 1
	self.height = height + 1
	self.tile_size = tile_size
	self.tile_map = tile_map
	self.tile_map_layer = tile_map_layer
	self.object_grid = nil
	self.maze_start_loc = { x = -1, y = -1 }
	self.maze_end_loc = { x = -1, y = -1 }
	self.maze_end_distance = 0
	
	self.walkable_tiles = {}
	
	init_object_grid()
	setup_maze()
	
	self.maze_end_distance = Grid:find_path(self.maze_start_loc, self.maze_end_loc).length

end

function Grid:set_tile(x, y, type)
	local node = ref.object_grid:get_cell(x, y)
	if node ~= nil then
		node.type = type
		ref.object_grid:set_cell(x, y, node)
	end
end

function Grid:redraw()

	local offset = (((ref.width - 1) - ref.maze_width) / 2) + 1
	
	for y = ref.height, 1, -1 do
		for x = 1, ref.width do
			
			local node = ref.object_grid:get_cell(x, y)
  			node.type = get_tile_type(x, y, node.type)
			tilemap.set_tile(ref.tile_map, ref.tile_map_layer, x, y, node.type)
			
		end
	end
		
	-- Corner walls
  	tilemap.set_tile(ref.tile_map, ref.tile_map_layer, offset, offset + ref.maze_height, TileType.wall_top_left)
	tilemap.set_tile(ref.tile_map, ref.tile_map_layer, offset + ref.maze_width, offset + ref.maze_height, TileType.wall_top_right)
  	tilemap.set_tile(ref.tile_map, ref.tile_map_layer, offset, offset, TileType.wall_bottom_left)
	tilemap.set_tile(ref.tile_map, ref.tile_map_layer, offset + ref.maze_width, offset, TileType.wall_bottom_right)
		
end

function get_tile_type(x, y, type)

	local top = ref.object_grid:get_cell(x, y + 1) 
  	local bottom = ref.object_grid:get_cell(x, y - 1)
  	local left = ref.object_grid:get_cell(x - 1, y)
  	local right = ref.object_grid:get_cell(x + 1, y)
  	
	--[[local offset = (((ref.width - 1) - ref.maze_width) / 2) + 1
	if x == offset + 1 and type == TileType.floor then
		return TileType.floor_left
	end--]]
  	
  	if type == TileType.floor or type == TileType.void then
  		return type
  	end
  	
  	-- Left
   	if ((left ~= nil and left.type == TileType.void) or left == nil) and (right ~= nil and right.type == TileType.floor) then
  		return TileType.wall_y
  	end
  	
  	-- Right
 	if ((right ~= nil and right.type == TileType.void) or right == nil) and (left ~= nil and left.type == TileType.floor) then
  		return TileType.wall_y
  	end
  	
  	-- Top
  	if ((top ~= nil and top.type == TileType.void) or top == nil) and (bottom ~= nil and bottom.type == TileType.floor) then
  		return TileType.wall_x
  	end
  	
  	-- Bottom
  	if ((bottom ~= nil and bottom.type == TileType.void) or bottom == nil) and (top ~= nil and top.type == TileType.floor) then
  		return TileType.wall_x
  	end
  	
  	-- Top cross
  	if ((top ~= nil and top.type == TileType.void) or top == nil) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.void) and (right ~= nil and right.type ~= TileType.void) then
  		return TileType.wall_cross_top
  	end
  	
  	-- Bottom cross
  	if ((bottom ~= nil and bottom.type == TileType.void) or bottom == nil) and (top ~= nil and top.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.void) and (right ~= nil and right.type ~= TileType.void) then
  		return TileType.wall_cross_bottom
  	end
  	
  	-- Left cross
  	if ((left ~= nil and left.type == TileType.void) or left == nil) and (right ~= nil and right.type ~= TileType.floor) and (top ~= nil and top.type ~= TileType.void) and (bottom ~= nil and bottom.type ~= TileType.void) then
  		return TileType.wall_cross_left
  	end
  	
  	-- Right cross
  	if ((right ~= nil and right.type == TileType.void) or right == nil) and (left ~= nil and left.type ~= TileType.floor) and (top ~= nil and top.type ~= TileType.void) and (bottom ~= nil and bottom.type ~= TileType.void) then
  		return TileType.wall_cross_right
  	end
  	
	-- Cross end
  	if ((left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type == TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor)) then
  		return TileType.wall_cross_end
  	end
  	
  	-- Inner top left
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_top_left
  	end
  	
  	-- Inner top right
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_top_right
  	end
  	
  	-- Inner bottom left
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_bottom_left
  	end
  	
  	-- Inner bottom right
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_bottom_right
  	end
  	
  	-- Inner vertical wall
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_y
  	end
  	
  	-- Inner horizontal wall
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_x
  	end
  	
  	-- Inner cross
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_cross_mid
  	end
  	
  	-- Inner bottom cross
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_cross_bottom
  	end
  	
  	-- Inner top cross
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_cross_top
  	end
  	
  	-- Inner cross left
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_cross_left
  	end
  	
  	-- Inner cross right
  	if ((top ~= nil and top.type ~= TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_cross_right
  	end

  	-- Inner right end
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type ~= TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_bottom_right
  	end
  	
  	-- Inner left end
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type == TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type ~= TileType.floor)) then
  		return TileType.wall_bottom_left
  	end
  	
  	-- Inner wall start
  	if ((top ~= nil and top.type == TileType.floor) and (bottom ~= nil and bottom.type ~= TileType.floor) and (left ~= nil and left.type == TileType.floor) and (right ~= nil and right.type == TileType.floor)) then
  		return TileType.wall_y
  	end
  	  	
  	return type
  	
end

function init_object_grid()
	ref.object_grid = grid.Grid(ref.width, ref.height, GRID_NIL_VALUE)
	for y = ref.height, 1, -1 do
		for x = 1, ref.width do
			local node = Tile(x, y, TileType.void)
			ref.object_grid:set_cell(x, y, node)
		end
	end
end


--[[ PATHFINDING --]]

function Grid:find_path(source, target)

	if source.y < (ref.height + 1) and target.y < (ref.height + 1) then
	
		local map = pathfinderMap()
	
		local path_data = {}
	
		local Grid = require("libraries/jumper.grid")
		local Pathfinder = require("libraries/jumper.pathfinder")
		
	  	local grid = Grid(map)
	  	local finder = Pathfinder(grid, 'ASTAR', 0)
	  	finder:setMode('ORTHOGONAL')
	  		
		local path = finder:getPath(source.x, (ref.height + 1) - source.y, target.x, (ref.height + 1) - target.y)
		if path then
		  	local data = {}
		  	for node, count in path:nodes() do
				table.insert(path_data, { x = node:getX(), y = (ref.height + 1) - node:getY() })
		  	end
			return { path = path_data, length = path:getLength() }
		end
	
	end
	
end

function pathfinderMap()
	local map = {}
	for y = ref.height, 1, -1 do
		local row = {}
		for x = 1, ref.height do
			local node = ref.object_grid:get_cell(x, y)
			local state = 1
			if isWalkable(node.type) then
				state = 0
			end
			table.insert(row, state)
		end
		table.insert(map, row)
	end
	return map
end

function Grid:walkable_tile(loc)
	local node = ref.object_grid:get_cell(loc.x, loc.y)
	if node == nil then
		return false
	end
	return isWalkable(node.type)
end

function isWalkable(type)
	return (type == TileType.floor or type == TileType.floor_left)
end

--[[ MAZE GENERATION --]]

dirs = {
	{x = 0, y = -2},
	{x = 2, y = 0},
	{x = -2, y = 0},
	{x = 0, y = 2},
}

function initialize_maze_grid(w, h)
	local a = {}
	for i = 1, h do
    	table.insert(a, {})
		for j = 1, w do
			table.insert(a[i], true)
		end
	end
	return a
end

function shuffle(t)
	for i = 1, #t - 1 do
		local r = math.random(i, #t)
		t[i], t[r] = t[r], t[i]
	end
end

function avg(a, b)
	return (a + b) / 2
end

function setup_maze()

	local offset = ((ref.width - 1) - ref.maze_width) / 2

	local w = (ref.maze_width) / 2
	local h = (ref.maze_height) / 2
	local map = initialize_maze_grid(w * 2 + 1, h * 2 + 1)
	
  	function walk(x, y)

    	map[y][x] = false
 
 		if ref.maze_start_loc.x == -1 then
			--ref.maze_start_loc = { x = x, y = ((ref.width + 1) - y) + offset }
			ref.maze_start_loc = { x = x + offset, y = ((ref.maze_width + 2) - y) + offset  }
		end
		
		--ref.maze_end_loc = { x = x, y = ((ref.width + 1) - y) + offset }
		--ref.maze_end_loc = { x = x, y = (ref.maze_width + 2) - y) + offset }
		ref.maze_end_loc = { x = x + offset, y = ((ref.maze_width + 2) - y) + offset  }
		table.insert(ref.walkable_tiles, ref.maze_end_loc)
 
    	local d = { 1, 2, 3, 4 }
    	shuffle(d)
    	
    	for i, dirnum in ipairs(d) do
      		local xx = x + dirs[dirnum].x
      		local yy = y + dirs[dirnum].y
      		if map[yy] and map[yy][xx] then
        		map[avg(y, yy)][avg(x, xx)] = false
				
				ref.maze_end_loc = { x = avg(x, xx) + offset, y = ((ref.maze_width + 2) - avg(y, yy)) + offset  }
				table.insert(ref.walkable_tiles, ref.maze_end_loc)
        		
        		walk(xx, yy)
      		end
    	end
	end
	
	walk(math.random(1, w) * 2, math.random(1, h) * 2)
	
	local s = {}
	for y = 1, h * 2 + 1 do
    	for x = 1, w * 2 + 1 do
      		if map[y][x] then
        		Grid:set_tile(x + offset, ((ref.maze_height + 2) - y) + offset, TileType.wall_plain)
        	else
        		Grid:set_tile(x + offset, ((ref.maze_height + 2) - y) + offset, TileType.floor)
      		end      		
    	end
  	end
	
	Grid:redraw()
	
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end
