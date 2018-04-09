print('server_tuning:init')

modname  = minetest .get_current_modname()
modpath  = minetest .get_modpath( modname )

local activeplayers  = 0

local max_u  = minetest .setting_get( 'max_users' )

local max_bsd  = minetest .setting_get( 'max_block_send_distance' )
local max_bgd   = minetest .setting_get( 'max_block_generate_distance' )
local max_sbspc  = minetest .setting_get( 'max_simultaneous_block_sends_per_client' )

local active_br   = minetest .setting_get( 'active_block_range' )
local active_osrb  = minetest .setting_get( 'active_object_send_range_blocks' )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- minetest .setting_get( 'name' )
-- minetest .setting_set( 'name', 'value' ) 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_joinplayer(  function(player)

    activeplayers  = activeplayers +1
    -- delay a moment for Minetest to initialize
    minetest .after( 2,  function()

        if minetest .get_player_privs(  player :get_player_name()  ) .server then

          minetest .chat_send_player(  player :get_player_name(),  
            'Welcome.  [server_tuning]  mod loaded, type   /server   to view info.'  )

        end  -- if privs()

      end  -- function()
    )  -- .after()

  end  -- function(player)
)  -- .register_on_joinplayer()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_leaveplayer(  function(player)

    activeplayers  = activeplayers -1

  end  -- function(player)
)  -- .register_on_leaveplayer()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function show_info( name )
	local formspec  = 'size[6,7]'

	  ..'label[0,1;max_users]'
	  ..'label[3,1;' ..max_u ..']'

	  ..'label[0,2;max_bsd]'
	  ..'label[3,2;' ..max_bsd ..']'
	  
	  ..'label[0,3;max_bgd]'
	  ..'label[3,3;' ..max_bgd ..']'

	  ..'label[0,4;max_sbspc]'
	  ..'label[3,4;' ..max_sbspc ..']'

	  ..'label[0,5;active_br]'
	  ..'label[3,5;' ..active_br ..']'
	  
	  ..'label[0,6;active_osrb]'
	  ..'label[3,6;' ..active_osrb ..']'

	minetest .show_formspec( name, 'server_tuning:show_info', formspec )
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_chatcommand( 'server', 
  {
    description  = 'show info',
    privs  = { server = true },  -- only show info to those who have 'server' priv
	  func  = function( name, param )
		  show_info( name )
	  end
  }
)  -- .register_chatcommand

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
