//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	matter = list("metal" = 1000, "glass" = 500, "waste" = 100)
	origin_tech = "magnets=2"

	wires = WIRE_PULSE

	secured = 0

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null

	proc
		trigger_beam()


	Destroy()
		if(first)
			qdel(first)
			first = null
		STOP_PROCESSING(SSobj, src)
		. = ..()

	activate()
		if(!..())	return 0//Cooldown check
		on = !on
		update_icon()
		return 1


	toggle_secure()
		secured = !secured
		if(secured)
			START_PROCESSING(SSobj, src)
		else
			on = 0
			if(first)
				qdel(first)
				first = null
			STOP_PROCESSING(SSobj, src)
		update_icon()
		return secured


	update_icon()
		overlays.Cut()
		attached_overlays = list()
		if(on)
			overlays += "infrared_on"
			attached_overlays += "infrared_on"

		if(holder)
			holder.update_icon()
		return


	process()//Old code
		if(!on)
			if(first)
				qdel(first)
				first = null
				return

		if((!(first) && (secured && (istype(loc, /turf) || (holder && istype(holder.loc, /turf))))))
			var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam((holder ? holder.loc : loc) )
			I.master = src
			I.density = 1
			I.setDir(dir)
			step(I, I.dir)
			if(I)
				I.density = 0
				first = I
				I.vis_spread(visible)
				spawn(0)
					if(I)
						//to_chat(world, "infra: setting limit")
						I.limit = 8
						//to_chat(world, "infra: processing beam \ref[I]")
						I.process()
					return
		return


	attack_hand()
		if(first)
			qdel(first)
			first = null
		..()


	Move()
		var/t = dir
		..()
		setDir(t)
		qdel(first)
		first = null
		return


	holder_movement()
		if(!holder)	return 0
//		setDir(holder.dir)
		qdel(first)
		first = null
		return 1


	trigger_beam()
		if((!secured)||(!on)||(cooldown > 0))	return 0
		pulse(0)
		if(!holder)
			visible_message("[bicon(src)] *beep* *beep*")
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	interact(mob/user as mob)//TODO: change this this to the wire control panel
		if(!secured)	return
		user.set_interaction(src)
		var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (on ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=infra")
		onclose(user, "infra")
		return


	Topic(href, href_list)
		..()
		if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !in_range(loc, usr))
			usr << browse(null, "window=infra")
			onclose(usr, "infra")
			return

		if(href_list["state"])
			on = !(on)
			update_icon()

		if(href_list["visible"])
			visible = !(visible)
			spawn(0)
				if(first)
					first.vis_spread(visible)

		if(href_list["close"])
			usr << browse(null, "window=infra")
			return

		if(usr)
			attack_self(usr)

		return


	verb/rotate()//This could likely be better
		set name = "Rotate Infrared Laser"
		set category = "Object"
		set src in usr

		setDir(turn(dir, 90))
		return



/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "i beam"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/item/device/assembly/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags_atom = NOINTERACT

/obj/effect/beam/i_beam/proc/hit()
	//to_chat(world, "beam \ref[src]: hit")
	if(master)
		//to_chat(world, "beam hit \ref[src]: calling master \ref[master].hit")
		master.trigger_beam()
	qdel(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	//to_chat(world, "i_beam \ref[src] : vis_spread")
	visible = v
	spawn(0)
		if(next)
			//to_chat(world, "i_beam \ref[src] : is next [next.type] \ref[next], calling spread")
			next.vis_spread(v)
		return
	return

/obj/effect/beam/i_beam/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/beam/i_beam/process()
	//to_chat(world, "i_beam \ref[src] : process")

	if((!loc || loc.density || !(master)))
	//	to_chat(world, "beam hit loc [loc] or no master [master], deleting")
		qdel(src)
		return
	//to_chat(world, "proccess: [src.left] left")

	if(left > 0)
		left--
	if(left < 1)
		if(!(visible))
			invisibility = 101
		else
			invisibility = 0
	else
		invisibility = 0


	//to_chat(world, "now [src.left] left")
	var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
	I.master = master
	I.density = 1
	I.setDir(dir)
	//to_chat(world, "created new beam \ref[I] at [I.x] [I.y] [I.z]")
	step(I, I.dir)

	if(I)
		//to_chat(world, "step worked, now at [I.x] [I.y] [I.z]")
		if(!(next))
			//to_chat(world, "no next")
			I.density = 0
			//to_chat(world, "spreading")
			I.vis_spread(visible)
			next = I
			spawn(0)
				//to_chat(world, "limit = [limit] ")
				if((I && limit > 0))
					I.limit = limit - 1
					//to_chat(world, "calling next process")
					I.process()
				return
		else
			//to_chat(world, "is a next: \ref[next], deleting beam \ref[I]")
			qdel(I)
	else
		//to_chat(world, "step failed, deleting \ref[next]")
		qdel(next)
		next = null
	spawn(10)
		process()
		return
	return

/obj/effect/beam/i_beam/Bump()
	qdel(src)
	return

/obj/effect/beam/i_beam/Bumped()
	hit()
	return

/obj/effect/beam/i_beam/Crossed(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam))
		return
	spawn(0)
		hit()
		return
	return

/obj/effect/beam/i_beam/Destroy()
	if(master)
		master = null
	if(next)
		qdel(next)
		next = null
	. = ..()

