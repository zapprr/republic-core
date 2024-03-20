# republic-core
An all-in-one, general purpose framework for menu-based FiveM servers. Originally spun off from code created for San Andreas Republic.

## Dependencies
This requires the following scripts to work:
- [NativeUILua_Reloaded](https://github.com/sdiaz/NativeUILua_Reloaded) (Must be named `NativeUILua_Reloaded`)
- [blip-info](https://github.com/glitchdetector/fivem-blip-info) (Must be named `blip_info`)
- [bob74_ipl](https://github.com/Bob74/bob74_ipl) (Must be named `bob74_ipl`)
- [pma-voice](https://github.com/AvarianKnight/pma-voice) (Must be named `pma-voice`)
- [discord_perms](https://github.com/logan-mcgee/discord_perms) (Must be named `discord_perms`)
- [rp-radio](https://github.com/AvarianKnight/rp-radio) (Must be named `rp-radio`)

## To-Do:
- Refactor code to make the codebase readable & expandable
- Ensure customisability is easy to do
- Fix any/all bugs
- Update from discord_perms to Discordroles INCLUDING CONFIG FOR SERVER ROLES PLEEEASE!!!
- Generally improve the experience for those installing this script onto a fresh server/integrating it into an existing one
- Make a list of all features (at this point there's so many in here we kinda need it)
- Figure out what licence we wanna publish this under (e.g. creative commons?)
- Props for Prop Menu

## Commands List
character_cl.lua
	character	Open Character Menu

props-cl.lua
	prop		Open Prop Menu

main-cl.lua
	dismiss		Dismiss a warning or advisory that you have recieved
	showid		WIP: Show Driver License
	playtime	Potentially Broken: Show your Playtime
	playerlist	Hide or show the player list
	hu			Toggle holding your hands up.
	hh			Toggle holding your holster.
	engine		Toggle engine.
	seatbelt	Toggle seatbelt.
	settings	Open/close the settings menu.
	vehicle		WIP: Open/close the vehicle spawning menu.
	session		Open/close the session menu.
	jobmenu		
	onduty		Go on duty.
	offduty		Go off duty.
	p			Panic button.
	jail		Send a player to jail.
	unjail		Take a player out of jail.
	hospital	Send a player to the hospital.
	unhospital 	Take a player out of the hospital.
	coroner		Send a player to the mortuary.
	uncoroner	Take a player out of the mortuary.
	job			
	postal		Set a waypoint to a specified postal code.
	trunk		Open/close the trunk of a vehicle.
	hood		Open/close the hood of a vehicle.
	bus			
	xmit		Depreciated.
	window		Open/close a specified window of a vehicle.
	door		Open/close a specified door of a vehicle.
	cuff		Handcuff a player. (NEEDS TO BE RESTRICTEDF)
	drag		Drag a player. 		( NEEDS TO BE RESTRICTED)
	rack		Law Enforcement: Rack a weapon in your patrol vehicle.
	unrack		Law Enforcement: Unrack a weapon in your patrol vehicle.
	drop		Drop your weapon on the ground.
	--dropslow
	firingmode	Change the firing mode of your weapon.t/

	dev			Staff/Dev: Toggle Developer Mode
	rs			Staff: Mark Report as Handled
	rd			Staff: Dismiss Report
	rr			Staff: Reply to Report

main-sv.lua
	deleteentity	Delete a specified entity.
	ft			
	rft
	char		Set your character's name.
	msg			Send a private chat message to another player.
	gme			Indicate that your character is doing something to all players
	me			Indicate that your character is doing something to nearby players.
	do			Describe something or answer role-play questions for nearby players.
	gdo			Describe something or answer role-play questions for all players.
	action		Describe something or answer role-play questions for nearby players. Alias for /do
	gaction		Describe something or answer role-play questions for all players. Alias for /gdo
	run			Run a plate/name.
	search		Search something.
	report		Quickly report another player to staff.

	aop			Staff: Set the current Area of Play.
	alert		Staff: Create an alert.
	aopvote		Staff: Start an AOP Vote
	warn		Staff: Warn a player.
	advise		Staff: Advise a player.
	kick		Staff: Kick a player from the server.
	tempban		Staff: Temporarily ban a player from the server.
	ban			Staff: Permanently ban a player from the server.
	unban		Staff: Unban a player from the server.
	staff 		Staff: Send a message in chat labelled with the staff tag.
	wl			Staff: Toggle the members-only whitelist.
	time		Staff: Change the time.
	smsg		Staff: Send a private chat message to another player with the staff tag.

mdt-cl.lua
	mdt
	busy
	bsy
	unavailable
	ua
	clear
	cl
	enroute
	er
	codesix
	c6
	code6
	onscene

newphone/base-cl.lua
	devphone

oldphone/phone-cl.lua
	pdk2

oldphone/phone-sv.lua
	copypasta

