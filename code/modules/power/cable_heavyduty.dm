/obj/item/stack/cable_coil/heavyduty
	name = "heavy cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"

/obj/structure/cable/heavyduty
	icon = 'icons/obj/power_cond_heavy.dmi'
	name = "large power cable"
	desc = "This cable is tough. It cannot be cut with simple hand tools."
	layer = BELOW_ATMOS_PIPE_LAYER

/obj/structure/cable/heavyduty/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact_tile)
		return

	if(iswirecutter(W))
		to_chat(usr, "<span class='notice'>These cables are too tough to be cut with those [W.name].</span>")
		return
	else if(iscablecoil(W))
		to_chat(usr, "<span class='notice'>You will need heavier cables to connect to these.</span>")
		return
	else
		..()

/obj/structure/cable/heavyduty/cableColor(var/colorC)
	return