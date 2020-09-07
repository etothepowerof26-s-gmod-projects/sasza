print( "Topdown Shooter Loaded" )

-- hook.Remove( 'CalcView', 'MyCalcView' )
bCursorInit = ( bCursorInit == nil ) and false or bCursorInit

hook.Add( "InitPostEntity", "ShowCursor", function()

	hook.Remove( "InitPostEntity", "ShowCursor" )
	gui.EnableScreenClicker( true )
	bCursorInit = true

end )

if not bCursorInit and not bTopDownInit then
	
	gui.EnableScreenClicker( true )
	bCursorInit = true

	print( "Autorefresh detected" )

end

local TopDownDist = 72 * 2
local lastzombo = SysTime()
local LockedOnEnt
hook.Add( "CalcView", "TopDown", function( ply, pos, angles, fov )
	local view = {
		origin = pos + Vector( 0, 0, TopDownDist ),
		angles = Angle(90, 0, 90),
		fov = fov,
		drawviewer = true
	}

	if( system.HasFocus() )then
		-- print( gui.ScreenToVector( input.GetCursorPos() ) )
		--[[
		
	
		]]
		local vec = gui.ScreenToVector( input.GetCursorPos() )
		local dist = math.Distance( 0, 0, input.GetCursorPos() )
		local tr = util.QuickTrace( LocalPlayer():GetPos() + Vector( 0, 0, LocalPlayer():OBBMaxs().z * 3 ), vec * dist ^ 2, LocalPlayer() )
		-- print(tr.HitPos)
	
		if( input.IsMouseDown( MOUSE_RIGHT ) )then
			local ps = tr.HitPos
			
			-- print( ply:GetShootPos(), tr.HitPos, tr.Entity )
			if SysTime() > lastzombo + .5 then
				RunConsoleCommand( "zombo", ps.x, ps.y, ps.z )
				lastzombo = SysTime()
			end
		end

		local newPos = ( ply:GetShootPos() - tr.HitPos )
		newPos = newPos:Angle()
		newPos = newPos + Angle(0, 180, 0)
		
		if( tr.Entity ~= game.GetWorld() )then
			-- newPos = ( ply:GetShootPos() - tr.Entity:GetPos() + Vector( 0, 0, tr.Entity:OBBCenter().z ) )
			-- newPos = newPos:Angle()
			-- newPos = newPos + Angle(0, 180, 0)
			LockedOnEnt = tr.Entity
		else
			ply:SetEyeAngles( newPos )
			LockedOnEnt = nil
		end
		-- print(vec)

	end

	return view
end )

--hook.Remove("SetupMove", "TopDown")

local testCases = 
{
	{ IN_FORWARD  , IN_MOVERIGHT, CB = function( playerYaw ) return playerYaw + 135  end },
	{ IN_FORWARD  , IN_MOVELEFT , CB = function( playerYaw ) return playerYaw + 45   end },

	{ IN_BACK     , IN_MOVERIGHT, CB = function( playerYaw ) return playerYaw - 135  end },
	{ IN_BACK     , IN_MOVELEFT , CB = function( playerYaw ) return playerYaw - 45   end },

	{ IN_FORWARD  , CB = function( playerYaw ) return playerYaw + 90  end },
	{ IN_BACK     , CB = function( playerYaw ) return playerYaw - 90  end },

	{ IN_MOVERIGHT, CB = function( playerYaw ) return playerYaw + 180 end },
	{ IN_MOVELEFT , CB = function( playerYaw ) return playerYaw       end }

}

hook.Add( "CreateMove", "TopDown", function( ucmd )
	-- setting view angles
	
	local vang = ucmd:GetViewAngles()
	
	if( !LockedOnEnt || !IsValid( LockedOnEnt ) )then
		vang.p = 5
	else
		-- newPos = ( ply:GetShootPos() - tr.Entity:GetPos() + Vector( 0, 0, tr.Entity:OBBCenter().z ) )
		-- newPos = newPos:Angle()
		-- newPos = newPos + Angle(0, 180, 0)
		local ply = LocalPlayer()
		vang = ( ply:GetShootPos() - ( LockedOnEnt:GetPos() + Vector( 0, 0, LockedOnEnt:OBBCenter().z ) ) ):Angle() - Angle( 0, 180, 0 )
		vang.p = -vang.p
	end
	
	ucmd:SetViewAngles( vang )
	
	-- attacking
	if( input.IsMouseDown( MOUSE_FIRST ) )then
		ucmd:SetButtons( bit.bor( ucmd:GetButtons(), IN_ATTACK ) )
	end

	-- 8 axis movement that disregards the cursor
	-- position
	local move = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 )
	local speed = math.sqrt( move.x * move.x + move.y * move.y )
	
	local playerYaw = LocalPlayer():EyeAngles().y
	local diffYaw

	for _, v in ipairs( testCases ) do
		local getn = #v
		local passed = 0
		for i = 1, getn do
			if ucmd:KeyDown( v[ i ] ) then
				passed = passed + 1
			end
		end

		if passed == getn then
			diffYaw = math.rad( v.CB( playerYaw ) )
			break
		end
	end

	if diffYaw then
		ucmd:SetForwardMove( math.cos( diffYaw ) * speed )
		ucmd:SetSideMove( math.sin( diffYaw ) * speed )
	end

end )



bTopDownInit = true