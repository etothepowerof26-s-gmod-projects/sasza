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

	print("Autorefresh detected")

end

local TopDownDist = 72 * 2
hook.Add( "CalcView", "TopDown", function( ply, pos, angles, fov )
	local view = {
		origin = pos + Vector( 0, 0, TopDownDist ),
		angles = Angle(90, 0, 90),
		fov = fov,
		drawviewer = true
	}

	if( system.HasFocus() )then
		-- print( gui.ScreenToVector( input.GetCursorPos() ) )
		local vec = gui.ScreenToVector( input.GetCursorPos() )
		local tr = util.QuickTrace(LocalPlayer():GetShootPos(), gui.ScreenToVector(gui.MousePos()),LocalPlayer())
		-- print(tr.HitPos)

		local newPos = ( ply:GetShootPos() - tr.HitPos )
		newPos = newPos:Angle()
		newPos = newPos + Angle(0, 180, 0)

		ply:SetEyeAngles( newPos )
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
	--if( mdata:KeyDown( IN_JUMP ) )then
	--	mdata:SetButtons( bit.band( mdata:GetButtons(), bit.bnot( IN_JUMP ) ) )
	--end
	--ucmd:SetForwardMove( 40 )
	

	local move = Vector( ucmd:GetForwardMove(), ucmd:GetSideMove(), 0 )
	local speed = math.sqrt( move.x * move.x + move.y * move.y )
	
	local playerYaw = LocalPlayer():EyeAngles().y
	local diffYaw

	for _, v in ipairs( testCases ) do
		local passed = 0
		for i = 1, #v do
			if ucmd:KeyDown( v[ i ] ) then
				passed = passed + 1
			end
		end

		if passed == #v then
			diffYaw = math.rad( v.CB( playerYaw ) )
			break
		end
	end

	if diffYaw then
		ucmd:SetForwardMove( math.cos( diffYaw ) * speed )
		ucmd:SetSideMove( math.sin( diffYaw ) * speed )
	end

	local vang = ucmd:GetViewAngles()
	vang.p = 0

	ucmd:SetViewAngles( vang )

	print(ucmd:GetViewAngles())
	-- mdata:SetSideSpeed( 1000 )
end )

--[[hook.Add("HUDPaint", "a", function()
	surface.SetDrawColor(255, 255, 255)

	--surface.DrawLine(ScrW()/2,ScrH()/2,input.GetCursorPos())

	surface.DrawLine(ScrW()/2,ScrH()/2-ScrH()/4,ScrW()/2,ScrH()/2)

	local new = LocalPlayer():GetPos() + (LocalPlayer():GetForward() * 60)
	local dat = new:ToScreen()
	surface.DrawLine(dat.x,dat.y, ScrW()/2,ScrH()/2)

	--surface.DrawLine(ScrW()/2,ScrH()/2+ScrH()/4,input.GetCursorPos())
end)]]

bTopDownInit = true