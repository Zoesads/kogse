--[[
  Base-Kogse Module
]]
local BaseKogse = {};
---@param length integer
function BaseKogse:New(length)
  assert(type(length) == "number" and length > 0 and math.floor(length) == length, "what");
  local _ = {};
  local c = {};
  local sz = length;
  local m = "0123456789abcdef";
  for i = 1, sz do
    c[i] = 0;
  end
  function _:Update()
    for i = 1, sz do
      if (c[i] < 36893488147419103231) then
        c[i] = c[i] + 1;
        return;
      end
    end
    sz = sz + 1;
    c[sz] = 1;
    return _;
  end
  function _:ConvertToString()
    local __res = "";
    for i = 1, sz do
      for j = 0, 15 do
        local z = ((bit.band(bit.rshift(c[i],bit.lshift(j,2)),bit.lshift(1,5)-1))%(#m))+1;
        __res = __res .. m:sub(z,z);
      end
    end
    return __res;
  end
  return _;
end
--// END OF BASE-KOGSE MODULE //--

--[[
  COLOR MODULE
]]
local Color = {};
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return Color
function Color.RGBA(r, g, b, a)
  assert(r>=0 and g>=0 and b>=0 and a>=0, "what the fuck");
  return {r,g,b,a};
end

---@param r integer
---@param g integer
---@param b integer
---@return Color
function Color.RGB(r, g, b)
  assert(r>=0 and g>=0 and b>=0, "what the fuck");
  return Color.RGBA(r,g,b,255);
end

---@param colorFrom Color Base color
---@param colorTo Color Target color
---@param step number
---@return Color
function Color.Lerp(colorFrom, colorTo, step)
  assert(type(step) == "number" and 0 <= step and step <= 1, "what the fuck");
  return Color.RGBA((1-step)*colorFrom[1] + step*colorTo[1],
                    (1-step)*colorFrom[2] + step*colorTo[2],
                    (1-step)*colorFrom[3] + step*colorTo[3],
                    (1-step)*colorFrom[4] + step*colorTo[4]);
end
--// END OF COLOR MODULE //--

--[[
  KOGSE MODULE
]]
---@param width number window's width
---@param height number window's height
---@param title string window's title
---@param maximum_fps integer maximum fps
local Kogse = {};
function Kogse:Init(width, height, title, maximum_fps)
  Kogse.window = {
    w = width;
    h = height;
    title = title;
  };
  Kogse.config = {
    max_fps = maximum_fps or 60;
  };
  Kogse.time = {previous = 0.0; now = 0.0; delta = 0.0;};
  Kogse.mouse = {x = 0, y = 0};
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param bg Color | nil
---@param border_width integer | nil
---@param border_color Color | nil
---@return nil
function Kogse:DrawRectangleNoRelative(x, y, w, h, bg, border_width, border_color)
  border_width = border_width or 0;
  if (type(border_width) == "number" and border_width > 0) then
    rl.DrawRectangleLinesEx({x-border_width, y-border_width,
                             w+border_width*2, h+border_width*2},
                            border_width, border_color or rl.PURPLE);
  end
  rl.DrawRectangleRec({x, y, w, h}, bg or rl.PURPLE);
end

---@param text string
---@param x number
---@param y number
---@param font_size number
---@param color Color | nil
---@return nil
function Kogse:DrawTextNoRelative(text, x, y, font_size, color)
  rl.DrawText(text, x, y, font_size, color or rl.BLACK);
end

function Kogse:CreateViewport(x, y, w, h, ox, oy)
  local __viewport = {
    x = 0;
    y = 0;
    w = w;
    h = h;
    origin = {
      x = ox or w/2;
      y = oy or h/2;
    };
    absolute_position = {
      x = x;
      y = y;
    };
    zoom = 1;
  }
  ---@param x number
  ---@return number
  function __viewport:TranslateFromViewportXToAbsoluteX(x)
    return (x+__viewport.x)*__viewport.zoom + __viewport.origin.x + __viewport.absolute_position.x;
  end
  ---@param y number
  ---@return number
  function __viewport:TranslateFromViewportYToAbsoluteY(y)
    return (y+__viewport.y)*__viewport.zoom + __viewport.origin.y + __viewport.absolute_position.y;
  end
  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param bg Color | nil
  ---@param border_width integer | nil
  ---@param border_color Color | nil
  ---@return nil
  function __viewport:DrawRectangle(x, y, w, h, bg, border_width, border_color)
    border_width = border_width or 0;
    if (type(border_width) == "number" and border_width > 0) then
      rl.DrawRectangleLinesEx({__viewport:TranslateFromViewportXToAbsoluteX(x-border_width),
                               __viewport:TranslateFromViewportYToAbsoluteY(y-border_width),
                               (w+2*border_width)*__viewport.zoom, (h+2*border_width)*__viewport.zoom},
                              border_width*__viewport.zoom, border_color or rl.PURPLE);
    end
    rl.DrawRectangleRec({__viewport:TranslateFromViewportXToAbsoluteX(x),
                         __viewport:TranslateFromViewportYToAbsoluteY(y),
                         w*__viewport.zoom, h*__viewport.zoom},
                        bg or rl.PURPLE);
  end
  ---@param text string
  ---@param x number
  ---@param y number
  ---@param font_size number
  ---@param color Color | nil
  ---@return nil
  function __viewport:DrawText(text, x, y, font_size, color)
    rl.DrawText(text, __viewport:TranslateFromViewportXToAbsoluteX(x),
                      __viewport:TranslateFromViewportYToAbsoluteY(y),
                 font_size*__viewport.zoom, color or rl.BLACK);
  end
  ---@param startp Vector2
  ---@param endp Vector2
  ---@param thickness number
  ---@param color Color
  function __viewport:DrawBezierCurve(startp, endp, thickness, color)
    rl.DrawLineBezier({__viewport:TranslateFromViewportXToAbsoluteX(startp.x), __viewport:TranslateFromViewportYToAbsoluteY(startp.y)},
                      {__viewport:TranslateFromViewportXToAbsoluteX(endp.x), __viewport:TranslateFromViewportYToAbsoluteY(endp.y)},
                      thickness,
                      color or rl.PURPLE);
  end
  ---@param a_x number
  ---@param a_y number
  ---@param a_w number
  ---@param a_h number
  ---@param b_x number
  ---@param b_y number
  ---@param b_w number
  ---@param b_h number
  ---@return boolean
  function __viewport:AABB(a_x, a_y, a_w, a_h, b_x, b_y, b_w, b_h)
    return (a_x + a_w) >= (b_x) and (b_x + b_w) >= (a_x) and
           (a_y + a_h) >= (b_y) and (b_y + b_h) >= (a_y);
  end
  ---@param a_x number
  ---@param a_y number
  ---@param a_w number
  ---@param a_h number
  ---@param mouse_x number
  ---@param mouse_y number
  ---@return boolean
  function __viewport:AABB_Mouse(a_x, a_y, a_w, a_h, mouse_x, mouse_y)
    return __viewport:TranslateFromViewportXToAbsoluteX(a_x+a_w) >= mouse_x-5 and
           mouse_x+5 >= __viewport:TranslateFromViewportXToAbsoluteX(a_x) and
           __viewport:TranslateFromViewportYToAbsoluteY(a_y+a_h) >= mouse_y-5 and
           mouse_y+5 >= __viewport:TranslateFromViewportYToAbsoluteY(a_y);
  end
  return __viewport;
end

---@param updateFunction function
---@return nil
function Kogse:Update(updateFunction)
  do
    local newMousePosition = rl.GetMousePosition();
    Kogse.mouse.x = newMousePosition.x;
    Kogse.mouse.y = newMousePosition.y;
  end
  do
    Kogse.time.now = rl.GetTime();
    local updateTime = Kogse.time.now - Kogse.time.previous;
    local waitTime = 1.0/Kogse.config.max_fps - updateTime;
    if (waitTime > 0) then
      rl.WaitTime(waitTime);
      Kogse.time.now = rl.GetTime();
      Kogse.time.delta = Kogse.time.now-Kogse.time.previous;
    end
    Kogse.time.previous = Kogse.time.now;
  end
  do
    updateFunction();
  end
end
--// END OF KOGSE MODULE //--


Kogse:Init(1000, 600, "very basic window", 240);
-- Kogse's components
local camera = Kogse.camera;
local mouse = Kogse.mouse;
local config = Kogse.config;
local time = Kogse.time;
local window = Kogse.window;

--[[
  BLOCK MODULE
]]
local BLOCK = {};
BLOCK.types = {
  ["GET.STR"] = 1;
  ["GET.INT"] = 2;
  ["ADD"] = 3;
  ["MUL"] = 4;
  ["SUB"] = 5;
  ["DIV"] = 6;
  ["DISPLAY"] = 7;
};
---@param type integer
---@param xpos number
---@param ypos number
---@return table
function BLOCK.NEW_BLOCK(type, xpos, ypos)
  local __block = {
    x = xpos;
    y = ypos;
    type = type;
  };
  return __block;
end
---@param block table
---@param port_name string
---@return Vector2
function BLOCK.GET_PORT_DISPLAY_POSITION(block, port_name)
  local __res = {x = 0, y = 0};
  if (block.type == BLOCK.types.ADD or block.type == BLOCK.types.SUB) then
    if (port_name == "I1") then
      __res.x = block.x + 2;
      __res.y = block.y + 25;
    elseif (port_name == "I2") then
      __res.x = block.x + 2;
      __res.y = block.y + 50;
    elseif (port_name == "O") then
      __res.x = block.x + 88;
      __res.y = block.y + 38;
    end
  elseif (block.type == BLOCK.types["GET.INT"]) then
    if (port_name == "O") then
      __res.x = block.x + 88;
      __res.y = block.y + 38;
    end
  elseif (block.type == BLOCK.types.DISPLAY) then
    if (port_name == "I1") then
      __res.x = block.x + 2;
      __res.y = block.y + 20;
    elseif (port_name == "I2") then
      __res.x = block.x + 2;
      __res.y = block.y + 40;
    elseif (port_name == "I3") then
      __res.x = block.x + 2;
      __res.y = block.y + 60;
    end
  end
  return __res;
end
BLOCK.all = {};
BLOCK.id = BaseKogse:New(12);
local selecting_block = {what="", id=""};
local typingBuffer = {
  value = "";
  size = 0;
};
--// END OF BLOCK MODULE //
--[[
  KOGSE INTERPRETER
]]
local KogInterpreter = {};
KogInterpreter.Result = {};
function KogInterpreter.ExecuteBlock(id_block)
  local blk = BLOCK.all[id_block];
  if (blk == nil) then
    return nil;
  end
  if (blk.type == BLOCK.types.ADD) then
    local block_possible_ports = {"I1", "I2"};
    local __res = {};
    for _, port_name in ipairs(block_possible_ports) do
      if (not blk[port_name]) then
        return nil;
      end
      local __child_res = KogInterpreter.ExecuteBlock(blk[port_name].des_id);
      if (type(__child_res) ~= "number") then
        return nil;
      end
      table.insert(__res, __child_res);
    end
    return __res[1] + __res[2];
  elseif (blk.type == BLOCK.types.SUB) then
    local block_possible_ports = {"I1", "I2"};
    local __res = {};
    for _, port_name in ipairs(block_possible_ports) do
      if (not blk[port_name]) then
        return nil;
      end
      local __child_res = KogInterpreter.ExecuteBlock(blk[port_name].des_id);
      if (type(__child_res) ~= "number") then
        return nil;
      end
      table.insert(__res, __child_res);
    end
    return __res[1] - __res[2];
  elseif (blk.type == BLOCK.types.DISPLAY) then
    local block_possible_ports = {{"I1", "__to_display"}, {"I2", "__des_x"}, {"I3", "__des_y"}};
    local __res = {
      __to_display = 0;
      __des_x = 0;
      __des_y = 0;
    };
    for _, __ in ipairs(block_possible_ports) do
      local port_name, des_name = unpack(__);
      if (not blk[port_name]) then
        return nil;
      end
      local __child_res = KogInterpreter.ExecuteBlock(blk[port_name].des_id);
      if (type(__child_res) ~= "number") then
        return nil;
      end
      __res[des_name] = __child_res;
    end
    return __res;
  elseif (blk.type == BLOCK.types["GET.INT"]) then
    return tonumber(blk.Value);
  end
end
--// END OF KOGSE INTERPRETER //--

local subwin = {
  ["editor"] = Kogse:CreateViewport(0, 30, window.w, window.h-30);
  ["toolbar"] = Kogse:CreateViewport(0, 0, window.w, 30, 0, 0);
  ["runner"] = Kogse:CreateViewport(0, 0, window.w, window.h);
};
local prev_mouse = {x = mouse.x, y = mouse.y};
local allScenes = {
  ["default"] = 1;
  ["booting"] = 2;
  ["running"] = 3;
};
local current_scene = allScenes["default"];
local display_fps = false;
local function Update()
  rl.BeginDrawing();
  rl.ClearBackground(rl.BLACK);
  local mouse_scroll_dt = rl.GetMouseWheelMove();
  local mouse_dt = {x = mouse.x-prev_mouse.x; y = mouse.y-prev_mouse.y};
  for sw_name, sw_view in pairs(subwin) do
    if (sw_view:AABB(sw_view.absolute_position.x, sw_view.absolute_position.y, sw_view.w, sw_view.h, mouse.x, mouse.y, 10, 10)) then
      -- print("hi mom", sw_name);
      if ((current_scene == allScenes["default"] and sw_name == "editor") or (current_scene == allScenes["running"] and sw_name == "runner")) then
        sw_view.zoom = math.max(0.01, math.min(sw_view.zoom + mouse_scroll_dt*0.5, 3));
        -- print(selecting_block.what, "hi");
        if (selecting_block.what ~= "navigating" and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) then
          sw_view.x = sw_view.x + 0.5*mouse_dt.x*(1/sw_view.zoom);
          sw_view.y = sw_view.y + 0.5*mouse_dt.y*(1/sw_view.zoom);
          -- print(sw_view.x, sw_view.y);
        end
      end
    end
  end
  prev_mouse.x = mouse.x;
  prev_moues.y = mouse.y;
  if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) then
    if (selecting_block.what == "navigating") then
      selecting_block.id = "";
      selecting_block.what = "";
    end
  end
  if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and selecting_block.what == "navigating") then
    -- Top panel of block, for navigating
    local collided = false;
    local navigate_block = BLOCK.all[selecting_block.id];
    local __dt_x = (subwin.editor:TranslateFromViewportXToAbsoluteX(navigate_block.x)-mouse.x)*(1/subwin.editor.zoom);
    local __dt_y = (subwin.editor:TranslateFromViewportYToAbsoluteY(navigate_block.y)-mouse.y)*(1/subwin.editor.zoom);
    for ___, ____ in pairs(BLOCK.all) do
      if (___ ~= selecting_block.id and subwin.editor:AABB(____.x, ____.y, 100, 75, navigate_block.x-__dt_x-50, navigate_block.y-__dt_y-5, 100, 75)) then
        collided = true;
        break;
      end
    end
    if (not collided) then
      -- print(__dt_x, __dt_y, mouse.x, mouse.y, subwin.editor:TranslateFromViewportXToAbsoluteX(navigate_block.x), subwin.editor:TranslateFromViewportYToAbsoluteY(navigate_block.y))
      BLOCK.all[selecting_block.id].x = navigate_block.x - __dt_x - 50;
      BLOCK.all[selecting_block.id].y = navigate_block.y - __dt_y - 5;
    end
  end
  if (rl.IsKeyPressed(rl.KEY_F2)) then
    display_fps = not display_fps;
  end
  if (rl.IsKeyPressed(rl.KEY_Q)) then
    if (current_scene == allScenes.default and selecting_block.what ~= "navigating") then
      selecting_block.id = "";
      selecting_block.what = "";
    elseif (current_scene == allScenes.running) then
      selecting_block.id = "";
      selecting_block.what = "";
      current_scene = allScenes.default;
    end
  end
  if (typingBuffer.size > 0 and selecting_block.what:find("typing") == nil) then
    typingBuffer.value = "";
    typingBuffer.size = 0;
  end
  if (selecting_block.what == "typing-number") then
    local key_and_num = {
      {rl.KEY_ONE, "1"},
      {rl.KEY_TWO, "2"},
      {rl.KEY_THREE, "3"},
      {rl.KEY_FOUR, "4"},
      {rl.KEY_FIVE, "5"},
      {rl.KEY_SIX, "6"},
      {rl.KEY_SEVEN, "7"},
      {rl.KEY_EIGHT, "8"},
      {rl.KEY_NINE, "9"},
      {rl.KEY_ZERO, "0"},
      {rl.KEY_MINUS, "-"}
    };
    for _, kn in ipairs(key_and_num) do
      if (rl.IsKeyPressed(kn[1])) then
        typingBuffer.value = typingBuffer.value .. kn[2];
        typingBuffer.size = typingBuffer.size + 1;
      end
    end
    if (rl.IsKeyPressed(rl.KEY_BACKSPACE) and typingBuffer.size > 0) then
      typingBuffer.size = typingBuffer.size - 1;
      typingBuffer.value = typingBuffer.size == 0 and "" or typingBuffer.value:sub(1, typingBuffer.size-1);
    end
    if (rl.IsKeyPressed(rl.KEY_ENTER)) then
      selecting_block.what = "";
      local translateToNumber = tonumber(typingBuffer.value);
      BLOCK.all[selecting_block.id].Value = translateToNumber and tostring(translateToNumber) or "0";
      selecting_block.id = "";
      typingBuffer.size = 0;
      typingBuffer.value = "";
    end
    -- print(typingBuffer.value, typingBuffer.size);
  elseif (current_scene == allScenes.default and selecting_block.what == "" or selecting_block.what == "navigating") then
    local spawn_pos_x = -subwin.editor.x-50;
    local spawn_pos_y = -subwin.editor.y-35;
    local spawn_id = BLOCK.id:ConvertToString();
    if (rl.IsKeyPressed(rl.KEY_ONE)) then
      BLOCK.all[spawn_id] = BLOCK.NEW_BLOCK(BLOCK.types.DISPLAY, spawn_pos_x, spawn_pos_y);
      BLOCK.id:Update();
    elseif (rl.IsKeyPressed(rl.KEY_TWO)) then
      BLOCK.all[spawn_id] = BLOCK.NEW_BLOCK(BLOCK.types.ADD, spawn_pos_x, spawn_pos_y);
      BLOCK.id:Update();
    elseif (rl.IsKeyPressed(rl.KEY_THREE)) then
      BLOCK.all[spawn_id] = BLOCK.NEW_BLOCK(BLOCK.types.SUB, spawn_pos_x, spawn_pos_y);
      BLOCK.id:Update();
    elseif (rl.IsKeyPressed(rl.KEY_FOUR)) then
      BLOCK.all[spawn_id] = BLOCK.NEW_BLOCK(BLOCK.types["GET.INT"], spawn_pos_x, spawn_pos_y);
      BLOCK.id:Update();
    end
  end

  if (current_scene == allScenes.default) then
    local loadOrder = {"editor", "toolbar"};
    for _, sw_name in ipairs(loadOrder) do
      local sw_view = subwin[sw_name];
      -- print(sw_name);
      if (sw_name == "editor") then
        -- Draw editor's background
        Kogse:DrawRectangleNoRelative(sw_view.absolute_position.x, sw_view.absolute_position.y, sw_view.w, sw_view.h, Color.RGB(20, 21, 22));
        --- Fun part, draw blocks (no it is not)
        --- Handle clicking stuff
        for id_block, blk in pairs(BLOCK.all) do
          if (id_block ~= selecting_block.id) then
            if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and (selecting_block.id == "" or selecting_block.id == "navigating") and sw_view:AABB_Mouse(blk.x, blk.y, 100, 15, mouse.x, mouse.y)) then
              selecting_block.what = "navigating";
              selecting_block.id = id_block;
            end
            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
              if (blk.type == BLOCK.types["GET.INT"]) then
                if (sw_view:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
                  -- Delete the block
                  local block_possible_ports = {"I1", "I2", "O"};
                  for _, port_name in ipairs(block_possible_ports) do
                    if (blk[port_name]) then
                      BLOCK.all[blk[port_name].des_id][blk[port_name].des_port_name] = nil;
                    end
                  end
                  BLOCK.all[id_block] = nil;
                  if (selecting_block.id == id_block) then
                    selecting_block.id = "";
                    selecting_block.what = "";
                  end
                elseif (sw_view:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
                  -- Update Block's Value
                  selecting_block.what = "typing-number";
                  selecting_block.id = id_block;
                  typingBuffer.size = 0;
                  typingBuffer.value = "";
                elseif (sw_view:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
                -- Connect to Block's Output port (=)
                  if (selecting_block.what == "") then
                    selecting_block.what = "O";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what:sub(1,1) == "I") then
                   local from_port = BLOCK.all[selecting_block.id][selecting_block.what];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.O ~= nil) then
                      BLOCK.all[blk.O.des_id][blk.O.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id][selecting_block.what] = {
                      des_id = id_block;
                      des_port_name = "O";
                      __parity = true;
                    };
                    blk.O = {
                      des_id = selecting_block.id;
                      des_port_name = selecting_block.what;
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                end
              elseif (blk.type == BLOCK.types.DISPLAY) then
                if (sw_view:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
                  -- Delete the block
                  local block_possible_ports = {"I1", "I2", "I3"};
                  for _, port_name in ipairs(block_possible_ports) do
                    if (blk[port_name]) then
                      BLOCK.all[blk[port_name].des_id][blk[port_name].des_port_name] = nil;
                    end
                  end
                  BLOCK.all[id_block] = nil;
                  if (selecting_block.id == id_block) then
                    selecting_block.id = "";
                    selecting_block.what = "";
                    typingBuffer.value = "";
                    typingBuffer.size = 0;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Input port 1 (Value)
                  if (selecting_block.what == "") then
                    selecting_block.what = "I1";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what == "O") then
                    local from_port = BLOCK.all[selecting_block.id]["O"];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.I1 ~= nil) then
                      BLOCK.all[blk.I1.des_id][blk.I1.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id]["O"] = {
                      des_id = id_block;
                      des_port_name = "I1";
                      __parity = true;
                    };
                    blk.I1 = {
                      des_id = selecting_block.id;
                      des_port_name = "O";
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Input port 2 (X)
                  if (selecting_block.what == "") then
                    selecting_block.what = "I2";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what == "O") then
                    local from_port = BLOCK.all[selecting_block.id]["O"];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.I2 ~= nil) then
                      BLOCK.all[blk.I2.des_id][blk.I2.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id]["O"] = {
                      des_id = id_block;
                      des_port_name = "I2";
                      __parity = true;
                    }
                    blk.I2 = {
                      des_id = selecting_block.id;
                      des_port_name = "O";
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Input port 3 (Y)
                  if (selecting_block.what == "") then
                    selecting_block.what = "I3";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what == "O") then
                    local from_port = BLOCK.all[selecting_block.id]["O"];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.I3 ~= nil) then
                      BLOCK.all[blk.I3.des_id][blk.I3.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id]["O"] = {
                      des_id = id_block;
                      des_port_name = "I3";
                      __parity = true;
                    }
                    blk.I3 = {
                      des_id = selecting_block.id;
                      des_port_name = "O";
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                end
              elseif (blk.type == BLOCK.types.ADD or blk.type == BLOCK.types.SUB) then
                if (sw_view:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
                  -- Delete the block
                  local block_possible_ports = {"I1", "I2", "O"};
                  for _, port_name in ipairs(block_possible_ports) do
                    if (blk[port_name]) then
                      BLOCK.all[blk[port_name].des_id][blk[port_name].des_port_name] = nil;
                    end
                  end
                  BLOCK.all[id_block] = nil;
                  if (selecting_block.id == id_block) then
                    selecting_block.id = "";
                    selecting_block.what = "";
                    typingBuffer.value = "";
                    typingBuffer.size = 0;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+2, blk.y+25, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Input port 1 (A)
                  if (selecting_block.what == "") then
                    selecting_block.what = "I1";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what == "O") then
                    local from_port = BLOCK.all[selecting_block.id]["O"];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.I1 ~= nil) then
                      BLOCK.all[blk.I1.des_id][blk.I1.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id]["O"] = {
                      des_id = id_block;
                      des_port_name = "I1";
                      __parity = true;
                    };
                    blk.I1 = {
                      des_id = selecting_block.id;
                      des_port_name = "O";
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+2, blk.y +50, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Input port 2 (B)
                  if (selecting_block.what == "") then
                    selecting_block.what = "I2";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what == "O") then
                    local from_port = BLOCK.all[selecting_block.id]["O"];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.I2 ~= nil) then
                      BLOCK.all[blk.I2.des_id][blk.I2.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id]["O"] = {
                      des_id = id_block;
                      des_port_name = "I2";
                      __parity = true;
                    }
                    blk.I2 = {
                      des_id = selecting_block.id;
                      des_port_name = "O";
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                elseif (sw_view:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
                  -- Connect to Block's Output port (=)
                  if (selecting_block.what == "") then
                    selecting_block.what = "O";
                    selecting_block.id = id_block;
                  elseif (selecting_block.what:sub(1,1) == "I") then
                   local from_port = BLOCK.all[selecting_block.id][selecting_block.what];
                    if (from_port ~= nil) then
                      BLOCK.all[from_port.des_id][from_port.des_port_name] = nil;
                    end
                    if (blk.O ~= nil) then
                      BLOCK.all[blk.O.des_id][blk.O.des_port_name] = nil;
                    end
                    BLOCK.all[selecting_block.id][selecting_block.what] = {
                      des_id = id_block;
                      des_port_name = "O";
                      __parity = true;
                    };
                    blk.O = {
                      des_id = selecting_block.id;
                      des_port_name = selecting_block.what;
                      __parity = true;
                    };
                    selecting_block.what = "";
                    selecting_block.id = "";
                    break;
                  end
                end
              end
            end
          end
        end
        --- Draw visual of those blocks
        for id_block, blk in pairs(BLOCK.all) do
          if (selecting_block.id == id_block) then
            sw_view:DrawRectangle(blk.x-2, blk.y-2, 104, 79, Color.RGB(44, 146, 214));
          end
          if (blk.type == BLOCK.types.ADD or blk.type == BLOCK.types.SUB) then
            sw_view:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(237, 207, 59));
            sw_view:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
            --- Delete button
            sw_view:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
            --- Input port 1
            if (sw_view:AABB_Mouse(blk.x+2, blk.y+25, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+2, blk.y+25, 10, 10,
                  blk.I1 and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+2, blk.y+25, 10, 10, blk.I1 and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
            end
            sw_view:DrawText("A", blk.x+15, blk.y+23, 15, rl.WHITE);
            --- Input port 2
            if (sw_view:AABB_Mouse(blk.x+2, blk.y +50, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+2, blk.y+50, 10, 10,
                  blk.I2 and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+2, blk.y+50, 10, 10, blk.I2 and rl.GREEN or rl.WHITE);
            end
            sw_view:DrawText("B", blk.x+15, blk.y+48, 15, rl.WHITE);
            --- Output port
            if (sw_view:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
                  blk.O and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O and rl.GREEN or rl.WHITE);
            end
            sw_view:DrawText("=", blk.x+75, blk.y+36, 15, rl.WHITE);
            sw_view:DrawText("A "..(blk.type==BLOCK.types.ADD and "+" or "-").." B", blk.x+5, blk.y+1, 15, rl.BLACK);
          elseif (blk.type == BLOCK.types.DISPLAY) then
            sw_view:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(52, 106, 193));
            sw_view:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
            --- Delete button
            sw_view:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
            --- Input port 1
            if (sw_view:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+2, blk.y+20, 10, 10,
                  blk.I1 and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+2, blk.y+20, 10, 10, blk.I1 and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
            end
            sw_view:DrawText("Value", blk.x+15, blk.y+22, 15, rl.WHITE);
            --- Input port 2
            if (sw_view:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+2, blk.y+40, 10, 10,
                  blk.I2 and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+2, blk.y+40, 10, 10, blk.I2 and rl.GREEN or rl.WHITE);
            end
            sw_view:DrawText("X", blk.x+15, blk.y+42, 15, rl.WHITE);
            --- Input port 3
            if (sw_view:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+2, blk.y+60, 10, 10,
                  blk.I3 and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+2, blk.y+60, 10, 10, blk.I3 and rl.GREEN or rl.WHITE);
            end
            sw_view:DrawText("Y", blk.x+15, blk.y+62, 15, rl.WHITE);
            sw_view:DrawText("DISPLAY", blk.x+5, blk.y+1, 15, rl.BLACK);
          elseif (blk.type == BLOCK.types["GET.INT"]) then
            sw_view:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(252, 162, 45));
            sw_view:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
            --- Delete button
            sw_view:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
            --- Value
            if (sw_view:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+5, blk.y+38, 70, 10,
                  Color.Lerp(Color.RGB(26, 29, 30), Color.RGB(35, 38, 40), 0.5));
            else
              sw_view:DrawRectangle(blk.x+5, blk.y+38, 70, 10, blk.I1 and Color.RGB(26, 29, 30) or Color.RGB(35, 38, 40));
            end
            sw_view:DrawText((selecting_block.what == "typing-number" and selecting_block.id == id_block) and typingBuffer.value or (blk.Value and (#blk.Value > 10 and (blk.Value:sub(1,10) .. "...") or blk.Value) or ""), blk.x + 6,blk.y + 38, 12, Color.RGB(247, 185, 42));
            --- Output port
            if (sw_view:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
              sw_view:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
                  blk.O and Color.Lerp(Color.RGB(24, 96, 23),
                  Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
                  0.5));
            else
              sw_view:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O and rl.GREEN or rl.WHITE);
            end
            sw_view:DrawText("INTEGER", blk.x+5, blk.y+1, 15, rl.BLACK);
          end
        end
        ---- Draw connection lines for those blocks
        for id_block, blk in pairs(BLOCK.all) do
          local block_possible_ports = {"I1", "I2", "I3", "O"};
          for _, port_name in ipairs(block_possible_ports) do
            if (blk[port_name]) then
              local target_block_info = blk[port_name];
              local tpid = target_block_info.des_id;
              local tpn = target_block_info.des_port_name;
              if (BLOCK.all[tpid][tpn].__parity == blk.__parity) then
                BLOCK.all[tpid][tpn].__parity = true;
                blk[port_name].__parity = true;
              else
                blk[port_name].__parity = false;
                sw_view:DrawBezierCurve(BLOCK.GET_PORT_DISPLAY_POSITION(blk, port_name), BLOCK.GET_PORT_DISPLAY_POSITION(BLOCK.all[tpid], tpn), 2, rl.GREEN);
              end
            end
          end
        end
        -- Draw spawning help
        Kogse:DrawTextNoRelative("1 - Spawn DISPLAY block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+5, 14, Color.RGB(52, 106, 193));
        Kogse:DrawTextNoRelative("2 - Spawn ADD block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+25, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("3 - Spawn SUB block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+45, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("4 - Spawn INTEGER block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+65, 14, Color.RGB(252, 162, 45));
        Kogse:DrawTextNoRelative("Q - Deselect block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+85, 14, rl.WHITE);
      elseif (sw_name == "toolbar") then
        ---# TOOLBAR #---
        -- Draw background
        sw_view:DrawRectangle(0, 0, sw_view.w, sw_view.h, Color.RGB(14, 15, 17));
        -- Draw toolbar's buttons
        local focused = false;
        if (sw_view:AABB_Mouse(5, 5, 50, 20, mouse.x, mouse.y)) then
          sw_view:DrawRectangle(5, 5, 50, 20, Color.RGB(170, 170, 170));
          sw_view:DrawText("RUN", 10, 6, 20, Color.RGB(120, 120, 120));
          if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
            current_scene = allScenes["running"];
            subwin.runner.x = 0;
            subwin.runner.y = 0;
            subwin.runner.zoom = 1;
            for i = 1, #KogInterpreter.Result do
              KogInterpreter.Result[i] = nil;
            end
            for id_block, __ in pairs(BLOCK.all) do
              if (__.type == BLOCK.types.DISPLAY) then
                local interpreted_result = KogInterpreter.ExecuteBlock(id_block);
                if (interpreted_result) then
                  table.insert(KogInterpreter.Result, {interpreted_result.__to_display, interpreted_result.__des_x, interpreted_result.__des_y});
                -- else
                --   print("FAILURE!!!!");
                end
              end
            end
          end
        else
          sw_view:DrawRectangle(5, 5, 50, 20, Color.RGB(36, 40, 48));
          sw_view:DrawText("RUN", 10, 6, 20, rl.WHITE);
        end
        if (not focused and sw_view:AABB_Mouse(60, 5, 63, 20, mouse.x, mouse.y)) then
          sw_view:DrawRectangle(60, 5, 63, 20, Color.RGB(170, 170, 170));
          sw_view:DrawText("CODE", 65, 6, 20, Color.RGB(120, 120, 120));
        else
          sw_view:DrawRectangle(60, 5, 63, 20, Color.RGB(36, 40, 48));
          sw_view:DrawText("CODE", 65, 6, 20, rl.WHITE);
        end
      end
    end
  elseif (current_scene == allScenes["running"]) then
    local sw_view = subwin.runner;
    Kogse:DrawRectangleNoRelative(sw_view.absolute_position.x, sw_view.absolute_position.y, sw_view.w, sw_view.h, rl.WHITE);
    Kogse:DrawTextNoRelative("Press Q to quit", 5, 5, 10, rl.BLACK);
    for _, to_cook in ipairs(KogInterpreter.Result) do
      local a, b, c = unpack(to_cook);
      -- print(a, b, c);
      sw_view:DrawText(tostring(a), b, c, 30, rl.BLACK);
    end
  end
  if (display_fps) then
    Kogse:DrawTextNoRelative("FPS: " .. tostring(math.ceil(1.0/math.max(time.delta,1/config.max_fps))), 10, 10, 20, rl.GREEN);
  end
  rl.EndDrawing();
end

-- No need to modify those code below
rl.SetConfigFlags(bit.bor(rl.FLAG_VSYNC_HINT, 0));
rl.InitWindow(window.w, window.h, window.title);
rl.SetTargetFPS(config.max_fps);
while not rl.WindowShouldClose() do
  Kogse:Update(Update);
end
rl.CloseWindow();
