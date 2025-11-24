@tool
extends Node2D

@export_tool_button("Fire") var fire_particle_btn: Callable = Callable(self, "fire")

# Fires the confetti particles.
func fire():
	$Particles1.emitting = true
	$Particles2.emitting = true
	$Particles3.emitting = true
