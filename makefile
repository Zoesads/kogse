RL_SRC=raylib-lua
RL_SCRIPT_MODE=$(RL_SRC)/raylua_s
RL_EMBED_MODE=$(RL_SRC)/raylua_e
RL_EMBED_NOTERM_MODE=$(RL_SRC)/raylua_r

dev:
	$(RL_SCRIPT_MODE) kogse.lua

build:
	$(RL_EMBED_MODE) kogse.lua
	mv src_out ./Kogse
	$(RL_EMBED_NOTERM_MODE) kogse.lua
	mv src_out ./Kogse_windows