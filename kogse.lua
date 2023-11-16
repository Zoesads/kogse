-- TODO: refactor code later (we really need to refactor the code)
-- TODO: document code

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


Kogse:Init(1240, 700, "Kogse v0.2a", 240);
-- Kogse's components
local camera = Kogse.camera;
local mouse = Kogse.mouse;
local config = Kogse.config;
local time = Kogse.time;
local window = Kogse.window;

--[[
  BLOCK MODULE
]]
---@alias PORT_t {connected_to: string, des: string, __parity: boolean}
---@alias BLOCK_t {x: number, y: number, type: integer, Value: nil | string, I1: nil | PORT_t, I2: nil | PORT_t, I3: nil | PORT_t, O: nil | PORT_t};

local BLOCK = {};
---@type table<string, BLOCK_t>
BLOCK.all = {};
BLOCK.id = BaseKogse:New(12);
---@type table<string, integer>
BLOCK.types = {
  ["GET.STR"] = 1;
  ["GET.INT"] = 2;
  ["ADD"] = 3;
  ["MUL"] = 4;
  ["SUB"] = 5;
  ["DIV"] = 6;
  ["DISPLAY"] = 7;
  ["COLOR"] = 9;
  ["VECTOR2"] = 10;
  ["RECTANGLE"] = 11;
};
---@type table<number, string[]>
BLOCK.available_ports = {
  [BLOCK.types["GET.STR"]] = {"O"};
  [BLOCK.types["GET.INT"]] = {"O"};
  [BLOCK.types.ADD] = {"I1", "I2", "O"};
  [BLOCK.types.SUB] = {"I1", "I2", "O"};
  [BLOCK.types.MUL] = {"I1", "I2", "O"};
  [BLOCK.types.DIV] = {"I1", "I2", "O"};
  [BLOCK.types.DISPLAY] = {"I1", "I2", "I3"};
  [BLOCK.types.VECTOR2] = {"I1", "I2", "O"};
  [BLOCK.types.COLOR] = {"I1", "I2", "I3", "O"};
  [BLOCK.types.RECTANGLE] = {"I1", "I2", "I3"};
}
---@param type integer
---@param xpos number
---@param ypos number
---@return BLOCK_t
function BLOCK.NEW_BLOCK(type, xpos, ypos)
  local __block = {
    x = xpos;
    y = ypos;
    type = type;
  };
  for _, port in ipairs(BLOCK.available_ports[type]) do
    __block[port] = {
      connected_to = "";
      des = "";
      __parity = true;
    };
  end
  return __block;
end
---@param block BLOCK_t
---@param port_name string
---@return Vector2
function BLOCK.GET_PORT_DISPLAY_POSITION(block, port_name)
  local __res = {x = 0, y = 0};
  if (block.type == BLOCK.types.VECTOR2 or block.type == BLOCK.types.ADD or block.type == BLOCK.types.SUB or block.type == BLOCK.types.DIV or block.type == BLOCK.types.MUL) then
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
  elseif (block.type == BLOCK.types["GET.INT"] or block.type == BLOCK.types["GET.STR"]) then
    if (port_name == "O") then
      __res.x = block.x + 88;
      __res.y = block.y + 38;
    end
  elseif (block.type == BLOCK.types.DISPLAY or block.type == BLOCK.types.RECTANGLE) then
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
  elseif (block.type == BLOCK.types.COLOR) then
    if (port_name == "I1") then
      __res.x = block.x + 2;
      __res.y = block.y + 20;
    elseif (port_name == "I2") then
      __res.x = block.x + 2;
      __res.y = block.y + 40;
    elseif (port_name == "I3") then
      __res.x = block.x + 2;
      __res.y = block.y + 60;
    elseif (port_name == "O") then
      __res.x = block.x + 88;
      __res.y = block.y + 38;
    end
  end
  return __res;
end
---@param block_id string
function BLOCK.DELETE(block_id)
  local blk = BLOCK.all[block_id];
  for _, port in ipairs(BLOCK.available_ports[blk.type]) do
    local target_id = blk[port].connected_to;
    if (target_id ~= "") then
      BLOCK.all[target_id][blk[port].des].connected_to = "";
    end
  end
  BLOCK.all[block_id] = nil
end
---@param block_type integer
---@param port_name string
function BLOCK.IS_VALID_PORT(block_type, port_name)
  if (not BLOCK.available_ports[block_type]) then
    return false;
  end
  for _, v in ipairs(BLOCK.available_ports[block_type]) do
    if (v == port_name) then
      return true;
    end
  end
  return false;
end
---@param A_id string
---@param B_id string
---@param loc string
---@param des string
function BLOCK.CONNECT(A_id, B_id, loc, des)
  local A = BLOCK.all[A_id];
  local B = BLOCK.all[B_id];
  local type_A = A.type;
  local type_B = B.type;
  if (not BLOCK.IS_VALID_PORT(type_A, loc) or not BLOCK.IS_VALID_PORT(type_B, des)) then
    return false;
  end
  if (A[loc].connected_to ~= "") then
    BLOCK.all[A[loc].connected_to][A[loc].des].connected_to = "";
  end
  if (B[des].connected_to ~= "") then
    BLOCK.all[B[des].connected_to][B[des].des].connected_to = "";
  end
  BLOCK.all[A_id][loc] = {
    connected_to = B_id;
    des = des;
    __parity = true;
  };
  BLOCK.all[B_id][des] = {
    connected_to = A_id;
    des = loc;
    __parity = true;
  };
  return true;
end
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
---@type table<number, fun(id: BLOCK_t): nil | table>
KogInterpreter.Executor = {
  [BLOCK.types.ADD] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.ADD]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        table.insert(res, child_res);
      end
    end
    if (type(res[1]) ~= type(res[2])) then
      return nil;
    elseif (type(res[1]) == "number") then
      return res[1] + res[2];
    elseif (type(res[1]) == "table" and #res[1] == 2 and #res[2] == 2) then
      return {res[1][1] + res[2][1], res[1][2] + res[2][2]};
    end
  end;
  [BLOCK.types.SUB] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.SUB]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if (type(child_res) ~= "number") then
          return nil;
        end
        table.insert(res, child_res);
      end
    end
    return res[1] - res[2];
  end;
  [BLOCK.types.MUL] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.MUL]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        table.insert(res, child_res);
      end
    end
    if (type(res[1]) ~= type(res[2])) then
      if (type(res[1]) == "table" and type(res[2]) == "number" and #res[1] == 2) then
        return {res[1][1]*res[2], res[1][2]*res[2]};
      elseif (type(res[2]) == "table" and #res[2] == 2 and type(res[1]) == "number") then
        return {res[2][1]*res[1], res[2][2]*res[1]};
      end
      return nil;
    else
      if (type(res[1]) == "number") then
        return res[1]*res[2];
      end
      return nil;
    end
  end;
  [BLOCK.types.DIV] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.DIV]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if (type(child_res) ~= "number") then
          return nil;
        end
        table.insert(res, child_res);
      end
    end
    return res[2] == 0 and nil or res[1] / res[2];
  end;
  [BLOCK.types.DISPLAY] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.DISPLAY]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if ((port_name == "I1" and child_res ~= nil) or (type(child_res) == "table" and ((port_name == "I2" and #child_res == 2) or (port_name == "I3" and #child_res == 3)))) then
          table.insert(res, child_res);
        else
          return nil;
        end
      end
    end
    return res;
  end;
  [BLOCK.types.RECTANGLE] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.DISPLAY]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if (type(child_res) ~= "table") then
          return nil;
        end
        if (((port_name == "I1" or port_name == "I2") and #child_res == 2) or (port_name == "I3" and #child_res == 3)) then
          table.insert(res, child_res);
        else
          return nil;
        end
      end
    end
    return res;
  end;
  [BLOCK.types["GET.INT"]] = function(blk)
    return tonumber(blk.Value);
  end;
  [BLOCK.types["GET.STR"]] = function(blk)
    return blk.Value;
  end;
  [BLOCK.types.COLOR] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.COLOR]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if (type(child_res) ~= "number") then
          return nil;
        end
        table.insert(res, child_res);
      end
    end
    return res;
  end;
  [BLOCK.types.VECTOR2] = function(blk)
    local res = {};
    for _, port_name in ipairs(BLOCK.available_ports[BLOCK.types.VECTOR2]) do
      if (not blk[port_name]) then
        return nil;
      end
      if (port_name ~= "O") then
        local child_res = KogInterpreter.ExecuteBlock(blk[port_name].connected_to);
        if (type(child_res) ~= "number") then
          return nil;
        end
        table.insert(res, child_res);
      end
    end
    return res;
  end
};
---@param id_block string
---@return table | nil
function KogInterpreter.ExecuteBlock(id_block)
  local blk = BLOCK.all[id_block];
  if (blk == nil) then
    return nil;
  end
  local exc = KogInterpreter.Executor[blk.type];
  if (type(exc) == "function") then
    return exc(blk);
  end
  return nil;
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
local function DrawBlocks()
  -- Draw visual of those blocks
  local editor = subwin.editor;
  for id_block, blk in pairs(BLOCK.all) do
    if (selecting_block.id == id_block) then
      editor:DrawRectangle(blk.x-2, blk.y-2, 104, 79, Color.RGB(44, 146, 214));
    end
    if (blk.type == BLOCK.types.ADD or blk.type == BLOCK.types.SUB or blk.type == BLOCK.types.MUL or blk.type == BLOCK.types.DIV) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(237, 207, 59));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Input port 1
      if (editor:AABB_Mouse(blk.x+2, blk.y+25, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+25, 10, 10,
            blk.I1.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+25, 10, 10, blk.I1.connected_to ~= "" and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
      end
      editor:DrawText("A", blk.x+15, blk.y+23, 15, rl.WHITE);
      -- Input port 2
      if (editor:AABB_Mouse(blk.x+2, blk.y +50, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+50, 10, 10,
            blk.I2.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+50, 10, 10, blk.I2.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("B", blk.x+15, blk.y+48, 15, rl.WHITE);
      -- Output port
      if (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
            blk.O.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("=", blk.x+75, blk.y+36, 15, rl.WHITE);
      if (blk.type == BLOCK.types.ADD) then
        editor:DrawText("A + B", blk.x+5, blk.y+1, 15, rl.BLACK);
      elseif (blk.type == BLOCK.types.SUB) then
        editor:DrawText("A - B", blk.x+5, blk.y+1, 15, rl.BLACK);
      elseif (blk.type == BLOCK.types.MUL) then
        editor:DrawText("A * B", blk.x+5, blk.y+1, 15, rl.BLACK);
      elseif (blk.type == BLOCK.types.DIV) then
        editor:DrawText("A / B", blk.x+5, blk.y+1, 15, rl.BLACK);
      end
    elseif (blk.type == BLOCK.types.DISPLAY) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(52, 106, 193));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Input port 1
      if (editor:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10,
            blk.I1.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10, blk.I1.connected_to ~= "" and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
      end
      editor:DrawText("CONTENT", blk.x+15, blk.y+22, 12, rl.WHITE);
      -- Input port 2
      if (editor:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10,
            blk.I2.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10, blk.I2.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("Position", blk.x+15, blk.y+42, 12, rl.WHITE);
      -- Input port 3
      if (editor:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10,
            blk.I3.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10, blk.I3.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("Color", blk.x+15, blk.y+62, 12, rl.WHITE);
      editor:DrawText("DISPLAY", blk.x+5, blk.y+1, 12, rl.BLACK);
    elseif (blk.type == BLOCK.types.RECTANGLE) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(81, 232, 161));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Input port 1
      if (editor:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10,
            blk.I1.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10, blk.I1.connected_to ~= "" and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
      end
      editor:DrawText("SIZE", blk.x+15, blk.y+22, 12, rl.WHITE);
      -- Input port 2
      if (editor:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10,
            blk.I2.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10, blk.I2.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("POSITION", blk.x+15, blk.y+42, 12, rl.WHITE);
      -- Input port 3
      if (editor:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10,
            blk.I3.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10, blk.I3.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("COLOR", blk.x+15, blk.y+62, 12, rl.WHITE);
      editor:DrawText("RECTANGLE", blk.x+5, blk.y+1, 12, rl.BLACK);
    elseif (blk.type == BLOCK.types.VECTOR2) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(41, 141, 229));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 12, rl.RED);
      -- Input port 1
      if (editor:AABB_Mouse(blk.x+2, blk.y+25, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+25, 10, 10,
            blk.I1.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+25, 10, 10, blk.I1.connected_to ~= "" and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
      end
      editor:DrawText("X", blk.x+15, blk.y+23, 12, rl.WHITE);
      -- Input port 2
      if (editor:AABB_Mouse(blk.x+2, blk.y +50, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+50, 10, 10,
            blk.I2.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+50, 10, 10, blk.I2.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("Y", blk.x+15, blk.y+48, 12, rl.WHITE);
      -- Output port
      if (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
            blk.O.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("VECTOR2", blk.x+5, blk.y+1, 15, rl.BLACK);
    elseif (blk.type == BLOCK.types.COLOR) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(174, 140, 219));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Input port 1
      if (editor:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10,
            blk.I1.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+20, 10, 10, blk.I1.connected_to ~= "" and Color.RGB(56, 232, 53) or Color.RGB(255, 255, 255));
      end
      editor:DrawText("R", blk.x+15, blk.y+22, 12, rl.WHITE);
      -- Input port 2
      if (editor:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10,
            blk.I2.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+40, 10, 10, blk.I2.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("G", blk.x+15, blk.y+42, 12, rl.WHITE);
      -- Input port 3
      if (editor:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10,
            blk.I3.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+2, blk.y+60, 10, 10, blk.I3.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("B", blk.x+15, blk.y+62, 12, rl.WHITE);
      -- Output port
      if (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
            blk.O.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("COLOR", blk.x+5, blk.y+1, 15, rl.BLACK);
    elseif (blk.type == BLOCK.types["GET.INT"]) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(252, 162, 45));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Value
      if (editor:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+5, blk.y+38, 70, 10,
            Color.Lerp(Color.RGB(26, 29, 30), Color.RGB(35, 38, 40), 0.5));
      else
        editor:DrawRectangle(blk.x+5, blk.y+38, 70, 10, Color.RGB(26, 29, 30));
      end
      editor:DrawText((selecting_block.what == "typing-number" and selecting_block.id == id_block) and typingBuffer.value or (blk.Value and (#blk.Value > 10 and (blk.Value:sub(1,10) .. "...") or blk.Value) or ""), blk.x + 6,blk.y + 38, 12, Color.RGB(247, 185, 42));
      -- Output port
      if (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
            blk.O.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("INTEGER", blk.x+5, blk.y+1, 15, rl.BLACK);
    elseif (blk.type == BLOCK.types["GET.STR"]) then
      editor:DrawRectangle(blk.x, blk.y, 100, 15, Color.RGB(252, 233, 90));
      editor:DrawRectangle(blk.x, blk.y+15, 100, 60, Color.RGB(15, 15, 15));
      -- Delete button
      editor:DrawText("x", blk.x+90, blk.y, 15, rl.RED);
      -- Value
      if (editor:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+5, blk.y+38, 70, 10,
            Color.Lerp(Color.RGB(26, 29, 30), Color.RGB(35, 38, 40), 0.5));
      else
        editor:DrawRectangle(blk.x+5, blk.y+38, 70, 10, Color.RGB(26, 29, 30));
      end
      editor:DrawText((selecting_block.what == "typing-string" and selecting_block.id == id_block) and typingBuffer.value or (blk.Value and (#blk.Value > 10 and (blk.Value:sub(1,10) .. "...") or blk.Value) or ""), blk.x + 6,blk.y + 38, 12, Color.RGB(247, 185, 42));
      -- Output port
      if (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10,
            blk.O.connected_to ~= "" and Color.Lerp(Color.RGB(24, 96, 23),
            Color.RGB(56, 232, 53), 0.5) or Color.Lerp(Color.RGB(180, 180, 180), Color.RGB(255, 255, 255),
            0.5));
      else
        editor:DrawRectangle(blk.x+88, blk.y+38, 10, 10, blk.O.connected_to ~= "" and rl.GREEN or rl.WHITE);
      end
      editor:DrawText("STRING", blk.x+5, blk.y+1, 15, rl.BLACK);
    end
  end
end
local function BlocksInteraction()
  local editor = subwin.editor;
  for id_block, blk in pairs(BLOCK.all) do
    if (id_block ~= selecting_block.id) then
      if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and (selecting_block.id == "" or selecting_block.id == "navigating") and editor:AABB_Mouse(blk.x, blk.y, 100, 15, mouse.x, mouse.y)) then
        selecting_block.what = "navigating";
        selecting_block.id = id_block;
      end
      if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
        if (blk.type == BLOCK.types["GET.INT"]) then
          if (editor:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
            -- Delete the block
            BLOCK.DELETE(id_block);
            if (selecting_block.id == id_block) then
              selecting_block.id = "";
              selecting_block.what = "";
            end
          elseif (editor:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
            -- Update Block's Value
            selecting_block.what = "typing-number";
            selecting_block.id = id_block;
            typingBuffer.size = 0;
            typingBuffer.value = "";
          elseif (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
          -- Connect to Block's Output port (=)
            if (selecting_block.what == "") then
              selecting_block.what = "O";
              selecting_block.id = id_block;
            elseif (selecting_block.what:sub(1,1) == "I") then
              BLOCK.CONNECT(id_block, selecting_block.id, "O", selecting_block.what);
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          end
        elseif (blk.type == BLOCK.types["GET.STR"]) then
          if (editor:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
            -- Delete the block
            BLOCK.DELETE(id_block);
            if (selecting_block.id == id_block) then
              selecting_block.id = "";
              selecting_block.what = "";
            end
          elseif (editor:AABB_Mouse(blk.x+5, blk.y+38, 70, 10, mouse.x, mouse.y)) then
            -- Update Block's Value
            selecting_block.what = "typing-string";
            selecting_block.id = id_block;
            typingBuffer.size = 0;
            typingBuffer.value = "";
          elseif (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
          -- Connect to Block's Output port (=)
            if (selecting_block.what == "") then
              selecting_block.what = "O";
              selecting_block.id = id_block;
            elseif (selecting_block.what:sub(1,1) == "I") then
              BLOCK.CONNECT(id_block, selecting_block.id, "O", selecting_block.what);
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          end
        elseif (blk.type == BLOCK.types.DISPLAY or blk.type == BLOCK.types.RECTANGLE) then
          if (editor:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
            -- Delete the block
            BLOCK.DELETE(id_block);
            if (selecting_block.id == id_block) then
              selecting_block.id = "";
              selecting_block.what = "";
              typingBuffer.value = "";
              typingBuffer.size = 0;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 1
            if (selecting_block.what == "") then
              selecting_block.what = "I1";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I1", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 2
            if (selecting_block.what == "") then
              selecting_block.what = "I2";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I2", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 3
            if (selecting_block.what == "") then
              selecting_block.what = "I3";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I3", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          end
        elseif (blk.type == BLOCK.types.COLOR) then
          if (editor:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
            -- Delete the block
            BLOCK.DELETE(id_block);
            if (selecting_block.id == id_block) then
              selecting_block.id = "";
              selecting_block.what = "";
              typingBuffer.value = "";
              typingBuffer.size = 0;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y+20, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 1
            if (selecting_block.what == "") then
              selecting_block.what = "I1";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I1", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y +40, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 2
            if (selecting_block.what == "") then
              selecting_block.what = "I2";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I2", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y +60, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 3
            if (selecting_block.what == "") then
              selecting_block.what = "I3";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I3", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Output port
            if (selecting_block.what == "") then
              selecting_block.what = "O";
              selecting_block.id = id_block;
            elseif (selecting_block.what:sub(1,1) == "I") then
              BLOCK.CONNECT(id_block, selecting_block.id, "O", selecting_block.what);
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          end
        elseif (blk.type == BLOCK.types.ADD or blk.type == BLOCK.types.SUB or blk.type == BLOCK.types.DIV or blk.type == BLOCK.types.MUL or blk.type == BLOCK.types.VECTOR2) then
          if (editor:AABB_Mouse(blk.x+90, blk.y, 15, 15, mouse.x, mouse.y)) then
            -- Delete the block
            BLOCK.DELETE(id_block);
            if (selecting_block.id == id_block) then
              selecting_block.id = "";
              selecting_block.what = "";
              typingBuffer.value = "";
              typingBuffer.size = 0;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y+25, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 1
            if (selecting_block.what == "") then
              selecting_block.what = "I1";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I1", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+2, blk.y +50, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Input port 2
            if (selecting_block.what == "") then
              selecting_block.what = "I2";
              selecting_block.id = id_block;
            elseif (selecting_block.what == "O") then
              BLOCK.CONNECT(id_block, selecting_block.id, "I2", "O");
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          elseif (editor:AABB_Mouse(blk.x+88, blk.y+38, 10, 10, mouse.x, mouse.y)) then
            -- Connect to Block's Output port
            if (selecting_block.what == "") then
              selecting_block.what = "O";
              selecting_block.id = id_block;
            elseif (selecting_block.what:sub(1,1) == "I") then
              BLOCK.CONNECT(id_block, selecting_block.id, "O", selecting_block.what);
              selecting_block.what = "";
              selecting_block.id = "";
              break;
            end
          end
        end
      end
    end
  end
end
local function VisualiseBlocksConnection()
  for id_block, blk in pairs(BLOCK.all) do
    for _, port_name in ipairs(BLOCK.available_ports[blk.type]) do
      local connection = blk[port_name];
      if (connection.connected_to ~= "") then
        if (BLOCK.all[connection.connected_to][connection.des].__parity ~= blk[port_name].__parity) then
          BLOCK.all[connection.connected_to][connection.des].__parity = true;
          blk[port_name].__parity = true;
        else
          blk[port_name].__parity = false;
          subwin.editor:DrawBezierCurve(BLOCK.GET_PORT_DISPLAY_POSITION(blk, port_name), BLOCK.GET_PORT_DISPLAY_POSITION(BLOCK.all[connection.connected_to], connection.des), 2, rl.GREEN);
        end
      end
    end
  end
end
---@param type integer
local function SpawnNewBlock(type)
  local spawn_pos_x = -subwin.editor.x-50;
  local spawn_pos_y = -subwin.editor.y-35;
  local spawn_id = BLOCK.id:ConvertToString();
  BLOCK.all[spawn_id] = BLOCK.NEW_BLOCK(type, spawn_pos_x, spawn_pos_y);
  BLOCK.id:Update();
  return spawn_id;
end
local function Update()
  rl.BeginDrawing();
  rl.ClearBackground(rl.BLACK);
  local mouse_scroll_dt = rl.GetMouseWheelMove();
  local mouse_dt = {x = mouse.x-prev_mouse.x; y = mouse.y-prev_mouse.y};
  for sw_name, sw_view in pairs(subwin) do
    if (sw_view:AABB(sw_view.absolute_position.x, sw_view.absolute_position.y, sw_view.w, sw_view.h, mouse.x, mouse.y, 10, 10)) then
      -- print("hi mom", sw_name);
      if ((current_scene == allScenes["default"] and sw_name == "editor") or (current_scene == allScenes["running"] and sw_name == "runner")) then
        sw_view.zoom = math.max(0.01, math.min(sw_view.zoom + mouse_scroll_dt*0.05, 2));
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
  prev_mouse.y = mouse.y;
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
    for _, blk in pairs(BLOCK.all) do
      if (_ ~= selecting_block.id and subwin.editor:AABB(blk.x, blk.y, 100, 75, navigate_block.x-__dt_x-50, navigate_block.y-__dt_y-5, 100, 75)) then
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
        typingBuffer.value = typingBuffer.value:sub(1, 29) .. kn[2];
      end
    end
    typingBuffer.size = #typingBuffer.value;
    if (rl.IsKeyPressed(rl.KEY_BACKSPACE) and typingBuffer.size > 0) then
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
  elseif (selecting_block.what == "typing-string") then
    local translate_keys = {
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
      {rl.KEY_MINUS, "-"},
      {rl.KEY_SPACE, " "};
      {rl.KEY_COMMA, ","};
      {rl.KEY_SEMICOLON, ";"};
    };
    for _, kn in ipairs(translate_keys) do
      if (rl.IsKeyPressed(kn[1])) then
        typingBuffer.value = typingBuffer.value:sub(1,1023) .. kn[2];
      end
    end
    typingBuffer.size = #typingBuffer.value;
    local chars = "ABCDEFGHIJKLMNOPQRSTVUWXYZ";
    local caps_down = rl.IsKeyDown(rl.KEY_CAPS_LOCK) and 1 or 0;
    local shift_down = (rl.IsKeyDown(rl.KEY_LEFT_SHIFT) or rl.IsKeyDown(rl.KEY_RIGHT_SHIFT)) and 1 or 0;
    local use_cap = bit.bxor(caps_down, shift_down) == 1;
    for i = 1, #chars do
      if (type(rl["KEY_" .. chars:sub(i,i)]) == "number" and rl.IsKeyPressed(rl["KEY_"..chars:sub(i,i)])) then
        typingBuffer.value = typingBuffer.value:sub(1,1023) .. (use_cap and chars:sub(i,i) or string.lower(chars:sub(i,i)));
      end
    end
    typingBuffer.size = #typingBuffer.value;
    if (rl.IsKeyPressed(rl.KEY_BACKSPACE) and typingBuffer.size > 0) then
      typingBuffer.value = typingBuffer.size == 0 and "" or typingBuffer.value:sub(1, typingBuffer.size-1);
    end
    if (rl.IsKeyPressed(rl.KEY_ENTER)) then
      selecting_block.what = "";
      BLOCK.all[selecting_block.id].Value = typingBuffer.value;
      selecting_block.id = "";
      typingBuffer.size = 0;
      typingBuffer.value = "";
    end
  elseif (current_scene == allScenes.default and selecting_block.what == "" or selecting_block.what == "navigating") then
    if (rl.IsKeyPressed(rl.KEY_ONE)) then
      SpawnNewBlock(BLOCK.types.DISPLAY);
    elseif (rl.IsKeyPressed(rl.KEY_TWO)) then
      SpawnNewBlock(BLOCK.types.ADD)
    elseif (rl.IsKeyPressed(rl.KEY_THREE)) then
      SpawnNewBlock(BLOCK.types.SUB)
    elseif (rl.IsKeyPressed(rl.KEY_FOUR)) then
      local block_id = SpawnNewBlock(BLOCK.types["GET.INT"])
      BLOCK.all[block_id].Value = "0";
    elseif (rl.IsKeyPressed(rl.KEY_FIVE)) then
      SpawnNewBlock(BLOCK.types.DIV);
    elseif (rl.IsKeyPressed(rl.KEY_SIX)) then
      SpawnNewBlock(BLOCK.types.MUL);
    elseif (rl.IsKeyPressed(rl.KEY_SEVEN)) then
      SpawnNewBlock(BLOCK.types.COLOR);
    elseif (rl.IsKeyPressed(rl.KEY_EIGHT)) then
      SpawnNewBlock(BLOCK.types.VECTOR2);
    elseif (rl.IsKeyPressed(rl.KEY_NINE)) then
      SpawnNewBlock(BLOCK.types.RECTANGLE);
    elseif (rl.IsKeyPressed(rl.KEY_ZERO)) then
      local block_id = SpawnNewBlock(BLOCK.types["GET.STR"])
      BLOCK.all[block_id].Value = "Hi kogse!";
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
        BlocksInteraction();
        DrawBlocks();
        VisualiseBlocksConnection();
        -- Draw spawning help
        Kogse:DrawTextNoRelative("1 - Spawn DISPLAY block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+5, 14, Color.RGB(52, 106, 193));
        Kogse:DrawTextNoRelative("2 - Spawn ADD block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+25, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("3 - Spawn SUB block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+45, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("4 - Spawn INTEGER block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+65, 14, Color.RGB(252, 162, 45));
        Kogse:DrawTextNoRelative("5 - Spawn DIV block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+85, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("6 - Spawn MUL block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+105, 14, Color.RGB(237, 207, 59));
        Kogse:DrawTextNoRelative("7 - Spawn COLOR block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+125, 14, Color.RGB(174, 140, 219));
        Kogse:DrawTextNoRelative("8 - Spawn VECTOR2 block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+145, 14, Color.RGB(41, 141, 229));
        Kogse:DrawTextNoRelative("9 - Spawn RECTANGLE block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+165, 14, Color.RGB(81, 232, 161));
        Kogse:DrawTextNoRelative("0 - Spawn STRING block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+185, 14, Color.RGB(252, 233, 90));
        Kogse:DrawTextNoRelative("Q - Deselect block", sw_view.absolute_position.x+5, sw_view.absolute_position.y+205, 14, rl.WHITE);
      elseif (sw_name == "toolbar") then
        --# TOOLBAR #---
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
            local err_cnt = 0;
            for id_block, blk in pairs(BLOCK.all) do
              if (blk.type == BLOCK.types.DISPLAY) then
                local interpreted_result = KogInterpreter.ExecuteBlock(id_block);
                if (interpreted_result) then
                  table.insert(KogInterpreter.Result, {"text", interpreted_result});
                else
                  table.insert(KogInterpreter.Result, {"text", {"ERROR: Unable to get DISPLAY content", {0, err_cnt*50}, {255, 0, 0}}})
                  err_cnt = err_cnt + 1;
                  -- print("FAILURE - DISPLAY");
                end
              elseif (blk.type == BLOCK.types.RECTANGLE) then
                local interpreted_result = KogInterpreter.ExecuteBlock(id_block);
                if (interpreted_result) then
                  table.insert(KogInterpreter.Result, {"rect", interpreted_result});
                else
                  table.insert(KogInterpreter.Result, {"text", {"ERROR: Unable to get RECTANGLE content", {0, err_cnt*50}, {255, 0, 0}}})
                  err_cnt = err_cnt + 1;
                  -- print("FAILURE - RECTANGLE");
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
      local a, b, c = unpack(to_cook[2]);
      -- print(to_cook[1]);
      if (to_cook[1] == "text") then
        -- print(a, b, c);
        sw_view:DrawText(tostring(a), b[1], b[2], 30, Color.RGB(c[1], c[2], c[3]));
      else
        sw_view:DrawRectangle(b[1], b[2], a[1], a[2], Color.RGB(c[1], c[2], c[3]));
      end
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