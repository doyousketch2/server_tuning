print('server_tuning:init')

modname  = minetest .get_current_modname()
modpath  = minetest .get_modpath( modname )

local activeplayers  = 0

local maxplayers       = minetest .setting_get( 'max_users' )
local maxgen           = minetest .setting_get( 'max_block_generate_distance' )
local maxblocksendper  = minetest .setting_get( 'max_simultaneous_block_sends_per_client' )

local blockrange     = minetest .setting_get( 'active_block_range' )
local sendrange      = minetest .setting_get( 'active_object_send_range_blocks' )
local blockdistance  = minetest .setting_get( 'max_block_send_distance' )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- minetest .setting_get( 'name' )
-- minetest .setting_set( 'name', 'value' ) 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_joinplayer(  function(player)
    minetest .after(  1, function()

    activeplayers  = activeplayers +1

  end )
end )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_leaveplayer(  function(player)

    activeplayers  = activeplayers -1

end )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
