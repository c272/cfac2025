extends Node

const TIME_GAUGE_MAX_TIME: float = 2.0

# Whether the game has started yet or not.
var game_started: bool = false

# The current time multiplier, remaining gauge time.
var time_multiplier: float = 1.0
var time_modify_gauge_time: float = TIME_GAUGE_MAX_TIME
var can_modify_time: bool = true

# The current score.
var current_score: int = 0
