include( "shared.lua" )

function GM:PlayerSpawn( ply )
	ply:SetModel( "models/player/kleiner.mdl" )
end 

function GM:PlayerLoadout( ply )
	ply:Give( "weapon_bbattles_base" )
end

function GM:PlayerSay( ply, txt )
	if( txt == "!spawn" )then
		ply:Spawn()
	elseif( txt == "!give" )then
		ply:Give( "weapon_bbattles_m16" )
		ply:GiveAmmo( 612, ply:GetActiveWeapon():GetPrimaryAmmoType() )
	end
	return txt
end

concommand.Add( "zombo", function( ply, _, args )
	local ent = ents.Create( "npc_zombie" )
	ent:Spawn()
	ent:SetPos( ply:GetPos() + ( ply:GetForward() * 200 ) ) 
	ply:SetPos( Vector( unpack( args ) ) )
end )