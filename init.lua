print('[server_tuning] init')

modname  = minetest .get_current_modname()
modpath  = minetest .get_modpath( modname )

local activeplayers  = 0
local max_u  = minetest .setting_get( 'max_users' )

local mod_storage  = minetest .get_mod_storage()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 0's are just placeholders, we'll retrieve values from mod_storage in a moment.

local max_bsd  = tonumber( minetest .setting_get( 'max_block_send_distance' ) )
local lo_bsd,  hi_bsd  = 0, 0

local max_bgd  = tonumber( minetest .setting_get( 'max_block_generate_distance' ) )
local lo_bgd,  hi_bgd  = 0, 0

local max_sbspc  = tonumber( minetest .setting_get( 'max_simultaneous_block_sends_per_client' ) )
local lo_sbspc,  hi_sbspc  = 0, 0

local active_br  = tonumber( minetest .setting_get( 'active_block_range' ) )
local lo_br,  hi_br  = 0, 0

local active_osrb  = tonumber( minetest .setting_get( 'active_object_send_range_blocks' ) )
local lo_osrb,  hi_osrb  = 0, 0

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  from global minetest.conf settings
--  minetest .setting_get( 'name' )
--  minetest .setting_set( 'name', 'value' )

--  from local mod settings
--  mod_storage :get_string( 'name' )
--  mod_storage :set_string( 'name', value )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--  uncomment next line to PRINT out the contents of [server_tuning] settings.
print( dump( mod_storage :to_table() ))

--  WARNING:  uncomment the next line to COMPLETELY CLEAR [server_tuning] settings, if need be.
mod_storage :from_table()

--=========================================================

xpcall(  -- protected call so that it can fall back to default values if none exist.
  function()  -- try to retrieve these values, if possible.
    lo_bsd  = mod_storage :get_int( 'lo_bsd' )
    hi_bsd  = mod_storage :get_int( 'hi_bsd' )

    lo_bgd  = mod_storage :get_int( 'lo_bgd' )
    hi_bgd  = mod_storage :get_int( 'hi_bgd' )

    lo_sbspc  = mod_storage :get_int( 'lo_sbspc' )
    hi_sbspc  = mod_storage :get_int( 'hi_sbspc' )

    lo_br  = mod_storage :get_int( 'lo_br' )
    hi_br  = mod_storage :get_int( 'hi_br' )

    lo_osrb  = mod_storage :get_int( 'lo_osrb' )
    hi_osrb  = mod_storage :get_int( 'hi_osrb' )
  end,

  function()  -- fallback to default values, if none were found in local storage.
    lo_bsd  = max_bsd
    hi_bsd  = max_bsd

    lo_bgd  = max_bgd
    hi_bgd  = max_bgd

    lo_sbspc  = max_sbspc
    hi_sbspc  = max_sbspc

    lo_br  = active_br
    hi_br  = active_br

    lo_osrb  = active_osrb
    hi_osrb  = active_osrb
  end
)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function col( color,  word )
  return minetest .colorize( color,  word )
end

local function round( num )
  return math.floor( num +0.5 )
end

local function minmax( num,  min,  max )
  if num < min then return min
  elseif num > max then return max
  else return num
  end
end

-- run variables through minmax function, in case minetest.conf has new values.

lo_bsd  = minmax( lo_bsd,  1,  max_bsd )
hi_bsd  = minmax( hi_bsd,  max_bsd,  hi_bsd )

lo_bgd  = minmax( lo_bgd,  1,  max_bgd )
hi_bgd  = minmax( hi_bgd,  max_bgd,  hi_bgd )

lo_sbspc  = minmax( lo_sbspc,  1,  max_sbspc )
hi_sbspc  = minmax( hi_sbspc,  max_sbspc,  hi_sbspc )

lo_br  = minmax( lo_br,  1,  active_br )
hi_br  = minmax( hi_br,  active_br,  hi_br )

lo_osrb  = minmax( lo_osrb,  1,  active_osrb )
hi_osrb  = minmax( hi_osrb,  active_osrb,  hi_osrb )

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
  local formspec  = 'size[10,7]'
    ..'bgcolor[#000000]'

    ..'label[0,0.25;users]'
    ..'label[6,0.25;' ..activeplayers ..']'
    ..'label[8,0.25;' ..max_u ..']'

    ..'label[3.8,1;' ..col( "#008888", "Low" ) ..']'
    ..'label[5.5,1;' ..col( "#009999", "Current" ) ..']'
    ..'label[7.8,1;' ..col( "#00AAAA", "High" ) ..']'


    ..'label[0,2;max_bsd]'

    ..'button[3,1.8;0.9,1;lo_bsd_d;v]'
    ..'label[4,2;' ..lo_bsd ..']'
    ..'button[4.6,1.8;0.9,1;lo_bsd_u;^]'

    ..'label[6,2;' ..max_bsd ..']'

    ..'button[7,1.8;0.9,1;hi_bsd_d;v]'
    ..'label[8,2;' ..hi_bsd ..']'
    ..'button[8.6,1.8;0.9,1;hi_bsd_u;^]'


    ..'label[0,3;max_bgd]'

    ..'button[3,2.8;0.9,1;lo_bgd_d;v]'
    ..'label[4,3;' ..lo_bgd ..']'
    ..'button[4.6,2.8;0.9,1;lo_bgd_u;^]'

    ..'label[6,3;' ..max_bgd ..']'

    ..'button[7,2.8;0.9,1;hi_bgd_d;v]'
    ..'label[8,3;' ..hi_bgd ..']'
    ..'button[8.6,2.8;0.9,1;hi_bgd_u;^]'


    ..'label[0,4;max_sbspc]'

    ..'button[3,3.8;0.9,1;lo_sbspc_d;v]'
    ..'label[4,4;' ..lo_sbspc ..']'
    ..'button[4.6,3.8;0.9,1;lo_sbspc_u;^]'

    ..'label[6,4;' ..max_sbspc ..']'

    ..'button[7,3.8;0.9,1;hi_sbspc_d;v]'
    ..'label[8,4;' ..hi_sbspc ..']'
    ..'button[8.6,3.8;0.9,1;hi_sbspc_u;^]'


    ..'label[0,5;active_br]'

    ..'button[3,4.8;0.9,1;lo_br_d;v]'
    ..'label[4,5;' ..lo_br ..']'
    ..'button[4.6,4.8;0.9,1;lo_br_u;^]'

    ..'label[6,5;' ..active_br ..']'

    ..'button[7,4.8;0.9,1;hi_br_d;v]'
    ..'label[8,5;' ..hi_br ..']'
    ..'button[8.6,4.8;0.9,1;hi_br_u;^]'


    ..'label[0,6;active_osrb]'

    ..'button[3,5.8;0.9,1;lo_osrb_d;v]'
    ..'label[4,6;' ..lo_osrb ..']'
    ..'button[4.6,5.8;0.9,1;lo_osrb_u;^]'

    ..'label[6,6;' ..active_osrb ..']'

    ..'button[7,5.8;0.9,1;hi_osrb_d;v]'
    ..'label[8,6;' ..hi_osrb ..']'
    ..'button[8.6,5.8;0.9,1;hi_osrb_u;^]'

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
