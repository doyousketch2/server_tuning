print('[server_tuning] init')

modname  = minetest .get_current_modname()
modpath  = minetest .get_modpath( modname )

-- set to true if you want to read what it's doing.

local printout_abms = false
local printout_lbms = false

-- set false if you don't need extra text in debug.txt
--=====================================

local ver  = 0  -- placeholder for ver in settings
local version  = '0.3'  -- actual script version
local activeplayers  = 0

local col1  = '#006666'
local col2  = '#009999'
local col3  = '#00AAAA'

local mod_storage  = minetest .get_mod_storage()
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  From global minetest.conf settings:

--  =/=  minetest .setting_get( 'name' )
--  =/=  minetest .setting_set( 'name', 'value' )

--  !!  Method recently changed to:

--  minetest .settings :get( 'name' )
--  minetest .settings :set( 'name', 'value' )

--  Arrive as strings, so change:   tonumber()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  From local mod_storage:

--  mod_storage :get_string( 'name' )
--  mod_storage :set_string( 'name', value )

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  WARNING:  uncomment the next line to COMPLETELY CLEAR [server_tuning] settings, if need be.
--  mod_storage :from_table()

--  uncomment next line to PRINT out the contents of [server_tuning] settings.
--  print( dump( mod_storage :to_table() ))

--=========================================================

local abms  = minetest .registered_abms
local lbms  = minetest .registered_lbms

local printout = function( label, info )
  local l3  = label :sub(1,3)
  if ( l3 == 'ABM' and printout_abms )
  or ( l3 == 'LBM' and printout_lbms ) then
    abms  = minetest .registered_abms
    lbms  = minetest .registered_lbms
    print( '~~~~~~~~~~~~~~  ' ..label )
    print( dump( info ) )
  end
end

--=====================================
-- increase time between ABM's to reduce lag

printout("ABM's Before:", abms)

for i = 1, #abms do
  local origin  = abms[i] .mod_origin
  local label  = abms[i] .label
  local interval  = abms[i] .interval

  if interval < 5 then
    abms[i] .interval  = 5  -- increase time
  elseif interval < 10 then
    abms[i] .interval  = interval *2
  elseif interval < 60 then
    abms[i] .interval  = interval *1.5
  elseif label == "mobs_animal:bee spawning" then
    abms[i] .interval  = interval *4  -- reduce bees
  end

  if origin == "farming"
  or label == "Grow cactus"
  or label == "Grow papyrus"
  or label == "Grass spread" then
    abms[i] .chance  = abms[i] .chance *0.75  -- increase chance 25%
  end -- increase chance to make up for added time
end

printout("ABM's After:", abms)

--=====================================
-- remove ancient LBM's

printout("LBM's Before:", lbms)

for i = #lbms, 1, -1 do  -- thanks jSnake, remove entries in reverse order, to keep index
  local origin  = lbms[i] .mod_origin

  if origin == "doors"
  or origin == "default"
  or origin == "farming"
  or origin == "xpanes"
   then
    table.remove( lbms, i )
  end
end

printout("LBM's After:", lbms)

--=========================================================

local function color( color,  word )
  return minetest .colorize( color,  word )
end


local function round( num )  -- 3 sig figs,  whole num if > 0.95
  local sigfig  = math.max(  1,  math.floor( num *1000 +0.5 ) /1000  )

  local floored  = math.floor(sigfig)
  local addafew  = math.floor(sigfig + 0.04)

  if addafew > floored then return addafew
  else return sigfig  end
end


local function gets( setting )  -- return a default if no number found
  if setting == 'max_block_send_distance' then
    return tonumber( minetest .settings :get(setting) )  or 6

  elseif setting == 'max_simultaneous_block_sends_per_client' then
    return tonumber( minetest .settings :get(setting) )  or 6

  elseif setting == 'max_block_generate_distance' then
    return tonumber( minetest .settings :get(setting) )  or 6

  elseif setting == 'chunksize' then
    return tonumber( minetest .settings :get(setting) )  or 5

  elseif setting == 'active_block_range' then
    return tonumber( minetest .settings :get(setting) )  or 3

  elseif setting == 'active_object_send_range_blocks' then
    return tonumber( minetest .settings :get(setting) )  or 3

  elseif setting == 'item_entity_ttl' then
    return tonumber( minetest .settings :get(setting) )  or 600

  elseif setting == 'liquid_loop_max' then
    return tonumber( minetest .settings :get(setting) )  or 100000

  elseif setting == 'liquid_update' then
    return tonumber( minetest .settings :get(setting) )  or 3

  elseif setting == 'max_users' then
    return tonumber( minetest .settings :get(setting) )  or 15

  else
    return tonumber( minetest .settings :get(setting) )  or 1
  end
end


local function sets( setting, num )
  if type(num) == 'number' and num > 0 then
    minetest .settings :set( setting, num )
  end
end

--=========================================================
-- generate step sizes, so they don't have to be calculated every time players join or part.

local max_users  = gets( 'max_users' )
local multiplier  = 1 / max_users

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_bsd  = gets( 'max_block_send_distance' )

local lo_bsd  = round( initial_bsd /3 )
local hi_bsd  = initial_bsd

local step_bsd  = lo_bsd / hi_bsd
local current_bsd  = round( hi_bsd - step_bsd * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_sbspc  = gets( 'max_simultaneous_block_sends_per_client' )

local lo_sbspc  = round( initial_sbspc /3 )
local hi_sbspc  = initial_sbspc

local step_sbspc  = lo_sbspc / hi_sbspc
local current_sbspc  = round( hi_sbspc - step_sbspc * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_bgd  = gets( 'max_block_generate_distance' )

local lo_bgd  = round( initial_bgd /3 )
local hi_bgd  = initial_bgd

local step_bgd  = lo_bgd / hi_bgd
local current_bgd  = round( hi_bgd - step_bgd * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_chunk  = gets( 'chunksize' )

local lo_chunk  = round( initial_chunk /3 )
local hi_chunk  = initial_chunk

local step_chunk  = lo_chunk / hi_chunk
local current_chunk  = round( hi_chunk - step_chunk * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_br  = gets( 'active_block_range' )

local lo_br  = round( initial_br /3 )
local hi_br  = initial_br

local step_br  = lo_br / hi_br
local current_br  = round( hi_br - step_br * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_osrb  = gets( 'active_object_send_range_blocks' )

local lo_osrb  = round( initial_osrb /3 )
local hi_osrb  = initial_osrb

local step_osrb  = lo_osrb / hi_osrb
local current_osrb  = round( hi_osrb - step_osrb * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_ttl  = gets( 'item_entity_ttl' )

local lo_ttl  = round( initial_ttl /3 )
local hi_ttl  = initial_ttl

local step_ttl  = lo_ttl / hi_ttl
local current_ttl  = round( hi_ttl - step_ttl * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_loop  = gets( 'liquid_loop_max' )

local lo_loop  = round( initial_loop /2 )
local hi_loop  = initial_loop

if initial_loop < 60000 then
  local lo_loop  = initial_loop
  local hi_loop  = round( initial_loop *2 )
end

local step_loop  = lo_loop / hi_loop
local current_loop  = round( hi_loop - step_loop * multiplier )
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local initial_liquid  = gets( 'liquid_update' )

local lo_liquid  = round( initial_liquid /3 )
local hi_liquid  = initial_liquid

if initial_liquid < 3 then
  lo_liquid  = initial_liquid
  hi_liquid  = round( initial_liquid *3 )
end

local step_liquid  = lo_liquid / hi_liquid
local current_liquid  = round( step_liquid * multiplier )
--=========================================================

xpcall(  function()  ver  = tonumber( mod_storage :get_string( 'ver' ) )  or 0  end,
         function()  end  )

if ver < tonumber( version ) then
  xpcall(  -- protected call, so that it can fall back to default values, if none exist.
    function()
      lo_bsd  = mod_storage :get_int( 'lo_bsd' )
      hi_bsd  = mod_storage :get_int( 'hi_bsd' )

      lo_sbspc  = mod_storage :get_int( 'lo_sbspc' )
      hi_sbspc  = mod_storage :get_int( 'hi_sbspc' )

      lo_bgd  = mod_storage :get_int( 'lo_bgd' )
      hi_bgd  = mod_storage :get_int( 'hi_bgd' )

      lo_chunk  = mod_storage :get_int( 'lo_chunk' )
      hi_chunk  = mod_storage :get_int( 'hi_chunk' )

      lo_br  = mod_storage :get_int( 'lo_br' )
      hi_br  = mod_storage :get_int( 'hi_br' )

      lo_osrb  = mod_storage :get_int( 'lo_osrb' )
      hi_osrb  = mod_storage :get_int( 'hi_osrb' )

      lo_ttl  = mod_storage :get_int( 'lo_ttl' )
      hi_ttl  = mod_storage :get_int( 'hi_ttl' )

      lo_loop  = mod_storage :get_int( 'lo_loop' )
      hi_loop  = mod_storage :get_int( 'hi_loop' )

      lo_liquid  = mod_storage :get_int( 'lo_liquid' )
      hi_liquid  = mod_storage :get_int( 'hi_liquid' )
    end,

    function()  -- fallback, if nothing were found in local storage.
    -- nothing to do here, as default values were set earlier.
    end  )
else -- no version found, so put default settings into mod_storage
  mod_storage :set_string( 'ver',  version )

  mod_storage :set_int( 'lo_bsd',  lo_bsd )
  mod_storage :set_int( 'hi_bsd',  hi_bsd )

  mod_storage :set_int( 'lo_sbspc',  lo_sbspc )
  mod_storage :set_int( 'hi_sbspc',  hi_sbspc )

  mod_storage :set_int( 'lo_bgd',  lo_bgd )
  mod_storage :set_int( 'hi_bgd',  hi_bgd )

  mod_storage :set_int( 'lo_chunk',  lo_chunk )
  mod_storage :set_int( 'hi_chunk',  hi_chunk )

  mod_storage :set_int( 'lo_br',  lo_br )
  mod_storage :set_int( 'hi_br',  hi_br )

  mod_storage :set_int( 'lo_osrb',  lo_osrb )
  mod_storage :set_int( 'hi_osrb',  hi_osrb )

  mod_storage :set_int( 'lo_ttl',  lo_ttl )
  mod_storage :set_int( 'hi_ttl',  hi_ttl )

  mod_storage :set_int( 'lo_loop',  lo_loop )
  mod_storage :set_int( 'hi_loop',  hi_loop )

  mod_storage :set_int( 'lo_liquid',  lo_liquid )
  mod_storage :set_int( 'hi_liquid',  hi_liquid )
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function currentsettings( )
  current_bsd  = round( hi_bsd - step_bsd * multiplier )
  sets( 'max_block_send_distance',  current_bsd )

  current_sbspc  = round( hi_sbspc - step_sbspc * multiplier )
  sets( 'max_simultaneous_block_sends_per_client',  current_sbspc )

  current_bgd  = round( hi_bgd - step_bgd * multiplier )
  sets( 'max_block_generate_distance',  current_bgd )

  current_chunk  = round( hi_chunk - step_chunk * multiplier )
  sets( 'chunksize',  current_chunk )

  current_br  = round( hi_br - step_br * multiplier )
  sets( 'active_block_range',  current_br )

  current_osrb  = round( hi_osrb - step_osrb * multiplier )
  sets( 'active_object_send_range_blocks',  current_osrb )

  current_ttl  = round( hi_ttl - step_ttl * multiplier )
  sets( 'item_entity_ttl',  current_ttl )

  current_loop  = round( hi_loop - step_loop * multiplier )
  sets( 'liquid_loop_max',  current_loop )

-- all above settings go hi'lo, liquid timer goes lo'hi instead
  current_liquid  = round( step_liquid * multiplier )
  sets( 'liquid_update',  current_liquid )
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_joinplayer(  function(player)
    activeplayers  = activeplayers +1
    multiplier  = activeplayers / max_users
    currentsettings( )

    -- delay a moment for Minetest to initialize
    minetest .after( 3,  function()
        local playername  = player :get_player_name()

        if minetest .get_player_privs( playername ) .server then

          minetest .chat_send_player( playername,
            'Welcome.  [server_tuning]  mod loaded, type   /server   to view menu.'  )

        end  -- if privs()

      end  -- function()
    )  -- .after()

  end  -- function(player)
)  -- .register_on_joinplayer()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

minetest .register_on_leaveplayer(  function(player)
    activeplayers  = activeplayers -1
    multiplier  = activeplayers / max_users
    currentsettings( )

  end  -- function(player)
)  -- .register_on_leaveplayer()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local function show_menu( playername )
  local formspec  = 'size[14,11]'

    ..'bgcolor[#000000DD]'
    ..'label[0,0.25;users]'

    ..'label[7.8,0.25;' ..color( col2, activeplayers ) ..']'
    ..'label[11,0.25;' ..color( col3, max_users ) ..']'

    ..'label[3.8,1;' ..color( col1, "Low" ) ..']'
    ..'label[7.6,1;' ..color( col2, "Current" ) ..']'
    ..'label[10.8,1;' ..color( col3, "High" ) ..']'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,2;max_bsd]'

    ..'button[3,1.8;0.75,1;lo_bsd_d;v]'
    ..'label[4,2;' ..color( col1, lo_bsd ) ..']'
    ..'button[5.8,1.8;0.75,1;lo_bsd_u;^]'

    ..'label[7.8,2;' ..color( col2, current_bsd ) ..']'

    ..'button[10,1.8;0.75,1;hi_bsd_d;v]'
    ..'label[11,2;' ..color( col3, hi_bsd ) ..']'
    ..'button[12.8,1.8;0.75,1;hi_bsd_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,3;max_sbspc]'

    ..'button[3,2.8;0.75,1;lo_sbspc_d;v]'
    ..'label[4,3;' ..color( col1, lo_sbspc ) ..']'
    ..'button[5.8,2.8;0.75,1;lo_sbspc_u;^]'

    ..'label[7.8,3;' ..color( col2, current_sbspc ) ..']'

    ..'button[10,2.8;0.75,1;hi_sbspc_d;v]'
    ..'label[11,3;' ..color( col3, hi_sbspc ) ..']'
    ..'button[12.8,2.8;0.75,1;hi_sbspc_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,4;max_bgd]'

    ..'button[3,3.8;0.75,1;lo_bgd_d;v]'
    ..'label[4,4;' ..color( col1, lo_bgd ) ..']'
    ..'button[5.8,3.8;0.75,1;lo_bgd_u;^]'

    ..'label[7.8,4;' ..color( col2, current_bgd ) ..']'

    ..'button[10,3.8;0.75,1;hi_bgd_d;v]'
    ..'label[11,4;' ..color( col3, hi_bgd ) ..']'
    ..'button[12.8,3.8;0.75,1;hi_bgd_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,5;chunk]'

    ..'button[3,4.8;0.75,1;lo_chunk_d;v]'
    ..'label[4,5;' ..color( col1, lo_chunk ) ..']'
    ..'button[5.8,4.8;0.75,1;lo_chunk_u;^]'

    ..'label[7.8,5;' ..color( col2, current_chunk ) ..']'

    ..'button[10,4.8;0.75,1;hi_chunk_d;v]'
    ..'label[11,5;' ..color( col3, hi_chunk ) ..']'
    ..'button[12.8,4.8;0.75,1;hi_chunk_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,6;active_br]'

    ..'button[3,5.8;0.75,1;lo_br_d;v]'
    ..'label[4,6;' ..color( col1, lo_br ) ..']'
    ..'button[5.8,5.8;0.75,1;lo_br_u;^]'

    ..'label[7.8,6;' ..color( col2, current_br ) ..']'

    ..'button[10,5.8;0.75,1;hi_br_d;v]'
    ..'label[11,6;' ..color( col3, hi_br ) ..']'
    ..'button[12.8,5.8;0.75,1;hi_br_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,7;active_osrb]'

    ..'button[3,6.8;0.75,1;lo_osrb_d;v]'
    ..'label[4,7;' ..color( col1, lo_osrb ) ..']'
    ..'button[5.8,6.8;0.75,1;lo_osrb_u;^]'

    ..'label[7.8,7;' ..color( col2, current_osrb ) ..']'

    ..'button[10,6.8;0.75,1;hi_osrb_d;v]'
    ..'label[11,7;' ..color( col3, hi_osrb ) ..']'
    ..'button[12.8,6.8;0.75,1;hi_osrb_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,8;item_entity_ttl]'

    ..'button[3,7.8;0.75,1;lo_ttl_d;v]'
    ..'label[4,8;' ..color( col1, lo_ttl ) ..']'
    ..'button[5.8,7.8;0.75,1;lo_ttl_u;^]'

    ..'label[7.8,8;' ..color( col2, current_ttl ) ..']'

    ..'button[10,7.8;0.75,1;hi_ttl_d;v]'
    ..'label[11,8;' ..color( col3, hi_ttl ) ..']'
    ..'button[12.8,7.8;0.75,1;hi_ttl_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,9;liquid_loop_max]'

    ..'button[3,8.8;0.75,1;lo_loop_d;v]'
    ..'label[4,9;' ..color( col1, lo_loop ) ..']'
    ..'button[5.8,8.8;0.75,1;lo_loop_u;^]'

    ..'label[7.8,9;' ..color( col2, current_loop ) ..']'

    ..'button[10,8.8;0.75,1;hi_loop_d;v]'
    ..'label[11,9;' ..color( col3, hi_loop ) ..']'
    ..'button[12.8,8.8;0.75,1;hi_loop_u;^]'
--~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ..'label[0,10;liquid_update]'

    ..'button[3,9.8;0.75,1;lo_liquid_d;v]'
    ..'label[4,10;' ..color( col1, lo_liquid ) ..']'
    ..'button[5.8,9.8;0.75,1;lo_liquid_u;^]'

    ..'label[7.8,10;' ..color( col2, current_liquid ) ..']'

    ..'button[10,9.8;0.75,1;hi_liquid_d;v]'
    ..'label[11,10;' ..color( col3, hi_liquid ) ..']'
    ..'button[12.8,9.8;0.75,1;hi_liquid_u;^]'

  minetest .show_formspec( playername,  'server_tuning:show_menu',  formspec )
end

--=========================================================

minetest .register_on_player_receive_fields(
  function( player, formname, fields )
    local playername  = player :get_player_name()

    local function recalculate_bsd()
      step_bsd  = lo_bsd / hi_bsd
      current_bsd  = round( hi_bsd - step_bsd * multiplier )
      sets( 'max_block_send_distance',  current_bsd )
    end

    local function recalculate_sbspc()
      step_sbspc  = lo_sbspc / hi_sbspc
      current_sbspc  = round( hi_sbspc - step_sbspc * multiplier )
      sets( 'max_simultaneous_block_sends_per_client',  current_sbspc )
    end

    local function recalculate_bgd()
      step_bgd  = lo_bgd / hi_bgd
      current_bgd  = round( hi_bgd - step_bgd * multiplier )
      sets( 'max_block_generate_distance',  current_bgd )
    end

    local function recalculate_chunk()
      step_chunk  = lo_chunk / hi_chunk
      current_chunk  = round( hi_chunk - step_chunk * multiplier )
      sets( 'chunksize',  current_chunk )
    end

    local function recalculate_br()
      step_br  = lo_br / hi_br
      current_br  = round( hi_br - step_br * multiplier )
      sets( 'active_block_range',  current_br )
    end

    local function recalculate_osrb()
      step_osrb  = lo_osrb / hi_osrb
      current_osrb  = round( hi_osrb - step_osrb * multiplier )
      sets( 'active_object_send_range_blocks',  current_osrb )
    end

    local function recalculate_ttl()
      step_ttl  = lo_ttl / hi_ttl
      current_ttl  = round( hi_ttl - step_ttl * multiplier )
      sets( 'item_entity_ttl',  current_ttl )
    end

    local function recalculate_loop()
      step_loop  = lo_loop / hi_loop
      current_loop  = round( hi_loop - step_loop * multiplier )
      sets( 'liquid_loop_max',  current_loop )
    end

    local function recalculate_liquid()
      step_liquid  = lo_liquid / hi_liquid
      current_liquid  = round( step_liquid * multiplier )
      sets( 'liquid_update',  current_liquid )
    end

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if formname ~= 'server_tuning:show_menu' then return false

    elseif fields .quit then
      return true

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_bsd_d then
      if lo_bsd > 1 then lo_bsd  = lo_bsd -1 end
      mod_storage :set_int( 'lo_bsd',  lo_bsd )
      recalculate_bsd()

    elseif fields .lo_bsd_u then
      if lo_bsd < hi_bsd then lo_bsd  = lo_bsd +1 end
      mod_storage :set_int( 'lo_bsd',  lo_bsd )
      recalculate_bsd()

    elseif fields .hi_bsd_d then
      if hi_bsd > 1 then hi_bsd  = hi_bsd -1 end
      mod_storage :set_int( 'hi_bsd',  hi_bsd )
      recalculate_bsd()

    elseif fields .hi_bsd_u then
      hi_bsd  = hi_bsd +1
      mod_storage :set_int( 'hi_bsd',  hi_bsd )
      recalculate_bsd()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_sbspc_d then
      if lo_sbspc > 1 then lo_sbspc  = lo_sbspc -1 end
      mod_storage :set_int( 'lo_sbspc',  lo_sbspc )
      recalculate_sbspc()

    elseif fields .lo_sbspc_u then
      if lo_sbspc < hi_sbspc then lo_sbspc  = lo_sbspc +1 end
      mod_storage :set_int( 'lo_sbspc',  lo_sbspc )
      recalculate_sbspc()

    elseif fields .hi_sbspc_d then
      if hi_sbspc > 1 then hi_sbspc  = hi_sbspc -1 end
      mod_storage :set_int( 'hi_sbspc',  hi_sbspc )
      recalculate_sbspc()

    elseif fields .hi_sbspc_u then
      hi_sbspc  = hi_sbspc +1
      mod_storage :set_int( 'hi_sbspc',  hi_sbspc )
      recalculate_sbspc()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_bgd_d then
      if lo_bgd > 1 then lo_bgd  = lo_bgd -1 end
      mod_storage :set_int( 'lo_bgd',  lo_bgd )
      recalculate_bgd()

    elseif fields .lo_bgd_u then
      if lo_bgd < hi_bgd then lo_bgd  = lo_bgd +1 end
      mod_storage :set_int( 'lo_bgd',  lo_bgd )
      recalculate_bgd()

    elseif fields .hi_bgd_d then
      if hi_bgd > 1 then hi_bgd  = hi_bgd -1 end
      mod_storage :set_int( 'hi_bgd',  hi_bgd )
      recalculate_bgd()

    elseif fields .hi_bgd_u then
      hi_bgd  = hi_bgd +1
      mod_storage :set_int( 'hi_bgd',  hi_bgd )
      recalculate_bgd()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_chunk_d then
      if lo_chunk > 1 then lo_chunk  = lo_chunk -1 end
      mod_storage :set_int( 'lo_chunk',  lo_chunk )
      recalculate_chunk()

    elseif fields .lo_chunk_u then
      if lo_chunk < hi_chunk then lo_chunk  = lo_chunk +1 end
      mod_storage :set_int( 'lo_chunk',  lo_chunk )
      recalculate_chunk()

    elseif fields .hi_chunk_d then
      if hi_chunk > 1 then hi_chunk  = hi_chunk -1 end
      mod_storage :set_int( 'hi_chunk',  hi_chunk )
      recalculate_chunk()

    elseif fields .hi_chunk_u then
      hi_chunk  = hi_chunk +1
      mod_storage :set_int( 'hi_chunk',  hi_chunk )
      recalculate_chunk()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_br_d then
      if lo_br > 1 then lo_br  = lo_br -1 end
      mod_storage :set_int( 'lo_br',  lo_br )
      recalculate_br()

    elseif fields .lo_br_u then
      if lo_br < hi_br then lo_br  = lo_br +1 end
      mod_storage :set_int( 'lo_br',  lo_br )
      recalculate_br()

    elseif fields .hi_br_d then
      if hi_br > 1 then hi_br  = hi_br -1 end
      mod_storage :set_int( 'hi_br',  hi_br )
      recalculate_br()

    elseif fields .hi_br_u then
      hi_br  = hi_br +1
      mod_storage :set_int( 'hi_br',  hi_br )
      recalculate_br()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_osrb_d then
      if lo_osrb > 1 then lo_osrb  = lo_osrb -1 end
      mod_storage :set_int( 'lo_osrb',  lo_osrb )
      recalculate_osrb()

    elseif fields .lo_osrb_u then
      if lo_osrb < hi_osrb then lo_osrb  = lo_osrb +1 end
      mod_storage :set_int( 'lo_osrb',  lo_osrb )
      recalculate_osrb()

    elseif fields .hi_osrb_d then
      if hi_osrb > 1 then hi_osrb  = hi_osrb -1 end
      mod_storage :set_int( 'hi_osrb',  hi_osrb )
      recalculate_osrb()

    elseif fields .hi_osrb_u then
      hi_osrb  = hi_osrb +1
      mod_storage :set_int( 'hi_osrb',  hi_osrb )
      recalculate_osrb()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_ttl_d then
      if lo_ttl > 10 then lo_ttl  = lo_ttl -10 end
      mod_storage :set_int( 'lo_ttl',  lo_ttl )
      recalculate_ttl()

    elseif fields .lo_ttl_u then
      if lo_ttl < hi_ttl then lo_ttl  = lo_ttl +10 end
      mod_storage :set_int( 'lo_ttl',  lo_ttl )
      recalculate_ttl()

    elseif fields .hi_ttl_d then
      if hi_ttl > 10 then hi_ttl  = hi_ttl -10 end
      mod_storage :set_int( 'hi_ttl',  hi_ttl )
      recalculate_ttl()

    elseif fields .hi_ttl_u then
      hi_ttl  = hi_ttl +10
      mod_storage :set_int( 'hi_ttl',  hi_ttl )
      recalculate_ttl()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_loop_d then
      if lo_loop > 1000 then lo_loop  = lo_loop -1000 end
      mod_storage :set_int( 'lo_loop',  lo_loop )
      recalculate_loop()

    elseif fields .lo_loop_u then
      if lo_loop < hi_loop then lo_loop  = lo_loop +1000 end
      mod_storage :set_int( 'lo_loop',  lo_loop )
      recalculate_loop()

    elseif fields .hi_loop_d then
      if hi_loop > 1000 then hi_loop  = hi_loop -1000 end
      mod_storage :set_int( 'hi_loop',  hi_loop )
      recalculate_loop()

    elseif fields .hi_loop_u then
      hi_loop  = hi_loop +1000
      mod_storage :set_int( 'hi_loop',  hi_loop )
      recalculate_loop()

    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    elseif fields .lo_liquid_d then
      if lo_liquid > 1 then lo_liquid  = lo_liquid -1 end
      mod_storage :set_int( 'lo_liquid',  lo_liquid )
      recalculate_liquid()

    elseif fields .lo_liquid_u then
      if lo_liquid < hi_liquid then lo_liquid  = lo_liquid +1 end
      mod_storage :set_int( 'lo_liquid',  lo_liquid )
      recalculate_liquid()

    elseif fields .hi_liquid_d then
      if hi_liquid > 1 then hi_liquid  = hi_liquid -1 end
      mod_storage :set_int( 'hi_liquid',  hi_liquid )
      recalculate_liquid()

    elseif fields .hi_liquid_u then
      hi_liquid  = hi_liquid +1
      mod_storage :set_int( 'hi_liquid',  hi_liquid )
      recalculate_liquid()

    end  -- if...elseif fields
    show_menu( playername )

  end  -- function( formname, fields )
)  -- .register_on_formspec_input()

--=========================================================

minetest .register_chatcommand( 'server',
  {
    description  = 'show info',
    privs  = { server = true },  -- only show menu to those who have 'server' priv
    func  = function( playername, param )
        show_menu( playername )
    end
  }
)  -- .register_chatcommand

--=========================================================
