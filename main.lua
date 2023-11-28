-- TODO: refactor code (automated code, clean and readable code, consistent notation, stable API)
-- TODO: document code

local Color = require("color");
local GUI = require("gui");
local GBlock = require("gblock");
local Executor = require("executor");

GUI.Init(1240, 700, "Kogse v0.2.2a", 240);
-- Kogse GUI's components
local camera = GUI.camera;
local mouse = GUI.mouse;
local config = GUI.config;
local time = GUI.time;
local window = GUI.window;

local global_box = GBlock.CreateBox();
---@type {[number]: number[]}
local block_occupied_area = {};
---@type {what: string, id: integer}
local selecting_block = {what="", id=-1};
---@type string[]
local rendering_order = {"title", "background", "close_btt", "input"};
---@type {value: string, size: integer}
local typingBuffer = {
  value = "";
  size = 0;
};
local right_click_menu = {activated = false; where = rl.new("Vector2", mouse.x, mouse.y)};
---@type Font
local FONT;

local child_windows = {
  ["editor"] = GUI.Viewport(0, 30, window.w, window.h-30);
  ["toolbar"] = GUI.Viewport(0, 0, window.w, 30, 0, 0);
  ["runner"] = GUI.Viewport(0, 0, window.w, window.h);
};
local prev_mouse = rl.new("Vector2", mouse.x, mouse.y);
local allScenes = {
  ["default"] = 1;
  ["booting"] = 2;
  ["running"] = 3;
};
local current_scene = allScenes["default"];
local display_fps = false;
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
  {rl.KEY_PERIOD, "."};
};
local translate_type_to_title = {
  [GBlock.types.ADD] = "A+B";
  [GBlock.types.SUB] = "A-B";
  [GBlock.types.MUL] = "A*B";
  [GBlock.types.DIV] = "A/B";
  [GBlock.types.COLOR] = "RGB";
  [GBlock.types.VECTOR2] = "VECTOR2";
  [GBlock.types.DISPLAY] = "DISPLAY";
  [GBlock.types.RECTANGLE] = "RECTANGLE";
  [GBlock.types["GET.INT"]] = "INTEGER";
  [GBlock.types["GET.STR"]] = "STRING";
  [GBlock.types.CIRCLE] = "CIRCLE";
  [GBlock.types.TRIANGLE] = "TRIANGLE";
};
local translate_pid_to_name = {
  I1 = {
    [GBlock.types.ADD] = "A";
    [GBlock.types.SUB] = "A";
    [GBlock.types.MUL] = "A";
    [GBlock.types.DIV] = "A";
    [GBlock.types.COLOR] = "R";
    [GBlock.types.VECTOR2] = "X";
    [GBlock.types.DISPLAY] = "CONTENT";
    [GBlock.types.RECTANGLE] = "SIZE";
    [GBlock.types.CIRCLE] = "RADIUS";
    [GBlock.types.TRIANGLE] = "A";
  };
  I2 = {
    [GBlock.types.ADD] = "B";
    [GBlock.types.SUB] = "B";
    [GBlock.types.MUL] = "B";
    [GBlock.types.DIV] = "B";
    [GBlock.types.COLOR] = "G";
    [GBlock.types.VECTOR2] = "Y";
    [GBlock.types.DISPLAY] = "POSITION";
    [GBlock.types.RECTANGLE] = "POSITION";
    [GBlock.types.CIRCLE] = "POSITION";
    [GBlock.types.TRIANGLE] = "B";
  };
  I3 = {
    [GBlock.types.COLOR] = "B";
    [GBlock.types.DISPLAY] = "COLOR";
    [GBlock.types.RECTANGLE] = "COLOR";
    [GBlock.types.CIRCLE] = "COLOR";
    [GBlock.types.TRIANGLE] = "C";
  };
  I4 = {
    [GBlock.types.RECTANGLE] = "ROTATION";
    [GBlock.types.TRIANGLE] = "COLOR";
  };
  O = {
    [GBlock.types.ADD] = "=";
    [GBlock.types.SUB] = "=";
    [GBlock.types.MUL] = "=";
    [GBlock.types.DIV] = "=";
  }
}
---@param block BLOCK_t
local function GetBlockTitle(block)
  assert(GBlock.block_graphical_data[block.type] and translate_type_to_title[block.type], "unimplemented title");
  return translate_type_to_title[block.type];
end
---@param block BLOCK_t
---@param port_id string
local function GetBlockPortName(block, port_id)
  assert(GBlock.block_graphical_data[block.type], "can't get port information from unknown block");
  return translate_pid_to_name[port_id][block.type] or "";
end
---@param block BLOCK_t
local function GetBlockColor(block)
  if (block.type == GBlock.types.ADD or block.type == GBlock.types.SUB or block.type == GBlock.types.MUL or block.type == GBlock.types.DIV) then
    return {
      title = Color.RGBA(237, 207, 59, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.VECTOR2) then
    return {
      title = Color.RGBA(41, 141, 229, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.DISPLAY) then
    return {
      title = Color.RGBA(52, 106, 193, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.COLOR) then
    return {
      title = Color.RGBA(174, 140, 219, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.RECTANGLE) then
    return {
      title = Color.RGBA(81, 232, 161, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.CIRCLE) then
    return {
      title = Color.RGBA(117, 168, 216, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types.TRIANGLE) then
    return {
      title = Color.RGBA(126, 153, 134, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
    }
  elseif (block.type == GBlock.types["GET.INT"]) then
    return {
      title = Color.RGBA(252, 162, 45, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
      input = Color.RGB(25, 25, 25);
    }
  elseif (block.type == GBlock.types["GET.STR"]) then
    return {
      title = Color.RGBA(252, 233, 90, 220);
      background = Color.RGBA(15, 15, 15, 175);
      close_btt = rl.RED;
      input = Color.RGB(25, 25, 25);
    }
  end
end

---@param id_block integer
local function DrawBlock(id_block)
  local editor = child_windows.editor;
  local block = global_box.all[id_block];
  if (block ~= nil) then
    if (selecting_block.id == id_block) then
      if (not block_occupied_area[block.type]) then
        block_occupied_area[block.type] = {0, 0};
        for _, gdata in pairs(GBlock.block_graphical_data[block.type]) do
          if (type(gdata) == "table" and #gdata >= 4) then
            block_occupied_area[block.type][1] = math.max(block_occupied_area[block.type][1], gdata[1]+gdata[3]);
            block_occupied_area[block.type][2] = math.max(block_occupied_area[block.type][2], gdata[2]+gdata[4]);
          end
        end
      end
      local oc_width, oc_height = unpack(block_occupied_area[block.type]);
      -- for some reason the oc_height value doesnt look right so i added +4 offset
      rl.BeginBlendMode(rl.BLEND_ADDITIVE);
      editor:DrawBackground(block.x-2, block.y-2, oc_width-1, oc_height+4, Color.RGBA(44, 146, 214, 150));
      editor:DrawBackground(block.x-2, block.y-2, oc_width-1, oc_height+4, Color.RGBA(44, 146, 214, 150));
      rl.EndBlendMode();
    end
    local Colors = GetBlockColor(block);
    local Title = GetBlockTitle(block);
    for _, component_name in ipairs(rendering_order) do
      local gdata = GBlock.block_graphical_data[block.type][component_name];
      if (gdata) then
        if (component_name == "input") then
          editor:DrawRoundedBackground(block.x+gdata[1], block.y+gdata[2], gdata[3], gdata[4], 0.25, Colors[component_name]);
        elseif (component_name ~= "close_btt") then
          editor:DrawBackground(block.x+gdata[1], block.y+gdata[2], gdata[3], gdata[4], Colors[component_name]);
        end
        if (component_name == "title") then
          editor:DrawTextEx(FONT, Title, block.x+gdata[1]+2, block.y+gdata[2], 15, rl.BLACK);
        elseif (component_name == "close_btt") then
          editor:DrawTextEx(FONT, "x", block.x+gdata[1], block.y+gdata[2], 14, rl.RED);
        elseif (component_name == "input") then
          editor:DrawTextEx(FONT, (selecting_block.id == id_block and selecting_block.what:sub(1,6) == "typing") and typingBuffer.value or (block.Value and (#block.Value > 10 and (block.Value:sub(1,10) .. "...") or block.Value)), block.x+gdata[1]+2, block.y+gdata[2]+2, 12, Color.RGB(247, 185, 42))
        end
      end
    end
    for port_name, port_gdata in pairs(GBlock.block_graphical_data[block.type].ports) do
      if (block[port_name].connected_to ~= "") then
        rl.BeginBlendMode(rl.BLEND_ADDITIVE);
        editor:DrawCircle(block.x+port_gdata[1], block.y+port_gdata[2], port_gdata[3], Color.RGBA(0, 200, 0, 200));
        editor:DrawCircle(block.x+port_gdata[1], block.y+port_gdata[2], port_gdata[3], Color.RGBA(0, 200, 0, 200));
        editor:DrawCircle(block.x+port_gdata[1], block.y+port_gdata[2], port_gdata[3], Color.RGBA(0, 200, 0, 200));
        rl.EndBlendMode();
      else
        editor:DrawCircle(block.x+port_gdata[1], block.y+port_gdata[2], port_gdata[3], rl.WHITE);
      end
      local identifier = GetBlockPortName(block, port_name);
      if (type(identifier) == "string" and identifier ~= "") then
        if (port_name:sub(1,1) == "I") then
          editor:DrawTextEx(FONT, identifier, block.x+port_gdata[1]+port_gdata[3]*2.3, block.y+port_gdata[2], 12, rl.WHITE);
        else
          editor:DrawTextEx(FONT, identifier, block.x+port_gdata[1]-port_gdata[3]*2.3, block.y+port_gdata[2], 12, rl.WHITE);
        end
      end
    end
  end
end

local function DrawBlocks()
  for zindex, _ in pairs(global_box.all) do
    if (selecting_block.what ~= "dragging" or selecting_block.id ~= zindex) then
      DrawBlock(zindex);
    end
  end
  if (selecting_block.what == "dragging") then
    DrawBlock(selecting_block.id);
  end
end

local function BlocksInteraction()
  local editor = child_windows.editor;
  -- print(selecting_block.what);
  for id_block, block in pairs(global_box.all) do
    if (id_block ~= selecting_block.id) then
      local touched = false;
      if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
        for port_name, port_gdata in pairs(GBlock.block_graphical_data[block.type].ports) do
          if (editor:IsMouseHover(block.x+port_gdata[1],block.y+port_gdata[2],2*port_gdata[3],2*port_gdata[3],mouse.x,mouse.y)) then
            touched = true;
            if (selecting_block.what == "" or selecting_block.id == -1) then
              selecting_block.what = port_name;
              selecting_block.id = id_block;
            elseif (port_name == "O" and selecting_block.what:sub(1,1) == "I") then
              global_box.MakeConnection(id_block, selecting_block.id, "O", selecting_block.what);
              selecting_block.what = "";
              selecting_block.id = -1;
              break;
            elseif (port_name:sub(1,1) == "I" and selecting_block.what == "O") then
              global_box.MakeConnection(id_block, selecting_block.id, port_name, "O");
              selecting_block.what = "";
              selecting_block.id = -1;
              break;
            end
          end
        end
      end
      if (not touched) then
        for part, gdata in pairs(GBlock.block_graphical_data[block.type]) do
          if (part ~= "ports" and editor:IsMouseHover(block.x+gdata[1],block.y+gdata[2],gdata[3],gdata[4],mouse.x,mouse.y)) then
            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
              if (part == "close_btt") then
                -- Delete the block
                global_box.DeleteBlock(id_block);
                if (selecting_block.id == id_block) then
                  selecting_block.id = -1;
                  selecting_block.what = "";
                end
                break;
              elseif (part == "input") then
                -- Update Block's Value
                selecting_block.what = block.type == GBlock.types["GET.INT"] and "typing-number" or "typing-string";
                selecting_block.id = id_block;
                typingBuffer.value = tostring(block.Value);
                typingBuffer.size = #typingBuffer.value;
              end
            elseif (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and selecting_block.id == -1 and part == "title" and selecting_block.what ~= "dragging") then
              selecting_block.what = "dragging";
              selecting_block.id = id_block;
            end
          end
        end
      end
    end
  end
end

local function VisualiseBlocksConnection()
  for _, block in pairs(global_box.all) do
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      local connection = block[port_name];
      if (connection.connected_to ~= "") then
        if (global_box.all[connection.connected_to][connection.des].__parity ~= block[port_name].__parity) then
          global_box.all[connection.connected_to][connection.des].__parity = true;
          block[port_name].__parity = true;
        else
          block[port_name].__parity = false;
          rl.BeginBlendMode(rl.BLEND_ADDITIVE);
          child_windows.editor:DrawBezierCurve(GBlock.GetPortDisplayPosition(block, port_name), GBlock.GetPortDisplayPosition(global_box.all[connection.connected_to], connection.des), 2, Color.RGBA(0, 200, 0, 255));
          child_windows.editor:DrawBezierCurve(GBlock.GetPortDisplayPosition(block, port_name), GBlock.GetPortDisplayPosition(global_box.all[connection.connected_to], connection.des), 2, Color.RGBA(0, 200, 0, 255));
          child_windows.editor:DrawBezierCurve(GBlock.GetPortDisplayPosition(block, port_name), GBlock.GetPortDisplayPosition(global_box.all[connection.connected_to], connection.des), 2, Color.RGBA(0, 200, 0, 255));
          rl.EndBlendMode();
        end
      end
    end
  end
end

---@param cwin table
---@param grid_color Color
local function DrawGrid(cwin, grid_color)
  local num_grid_line = math.ceil(20/cwin.zoom);
  local num_cell = window.w/num_grid_line;
  local line_size = num_cell/32;
  local line_color = grid_color;
  local right_most = cwin.absolute_position.x + cwin.w;
  local bottom_most = cwin.absolute_position.y + cwin.h;
  for i = 0, num_grid_line do
    local line_x = i*num_cell+cwin.x*cwin.zoom;
    if (line_x <= right_most) then
      if (line_x >= 0) then
        GUI.DrawBackground(line_x, 0, line_size, window.h, line_color);
      else
        GUI.DrawBackground(line_x+right_most*math.floor(1 + math.abs(line_x/right_most)), 0, line_size, window.h, line_color);
      end
    else
      GUI.DrawBackground(line_x-right_most*math.floor(line_x/right_most), 0, line_size, window.h, line_color);
    end
  end
  num_grid_line = math.ceil(20/cwin.zoom);
  -- by the time i write this there's a weird displaying issue happens if the number of lines is odd
  if (num_grid_line % 2 == 1) then
    num_grid_line = num_grid_line + 1;
  end
  num_cell = window.h/num_grid_line;
  line_size = num_cell/16;
  for i = 0, num_grid_line, 2 do
    local line_y = i*num_cell+cwin.y*cwin.zoom;
    if (line_y <= bottom_most) then
      if (line_y >= 0) then
        GUI.DrawBackground(0, line_y, window.w, line_size, line_color);
      else
        GUI.DrawBackground(0, line_y+bottom_most*math.floor(1 + math.abs(line_y/bottom_most)), window.w, line_size, line_color);
      end
    else
      GUI.DrawBackground(0, line_y-bottom_most*math.floor(line_y/bottom_most), window.w, line_size, line_color);
    end
  end
end

---@param type integer
local function SpawnNewBlock(type)
  local spawn_pos_x = -child_windows.editor.x-(GBlock.block_graphical_data[type].background[1]+GBlock.block_graphical_data[type].title[1])/2;
  local spawn_pos_y = -child_windows.editor.y-(GBlock.block_graphical_data[type].background[2]+GBlock.block_graphical_data[type].title[2])/2;
  local spawn_id = global_box.NewBlock(type, spawn_pos_x, spawn_pos_y);
  return spawn_id;
end

local function DrawEditor()
  local cwin = child_windows["editor"];
  GUI.DrawBackground(cwin.absolute_position.x, cwin.absolute_position.y, cwin.w, cwin.h, Color.RGB(20, 21, 22));
  DrawGrid(cwin, Color.RGB(30, 31, 32));
  BlocksInteraction();
  DrawBlocks();
  VisualiseBlocksConnection();
  -- Draw spawning help
  GUI.DrawTextEx(FONT, "1 - Spawn DISPLAY block", cwin.absolute_position.x+5, cwin.absolute_position.y+5, 20, Color.RGB(52, 106, 193));
  GUI.DrawTextEx(FONT, "2 - Spawn ADD block", cwin.absolute_position.x+5, cwin.absolute_position.y+25, 20, Color.RGB(237, 207, 59));
  GUI.DrawTextEx(FONT, "3 - Spawn SUB block", cwin.absolute_position.x+5, cwin.absolute_position.y+45, 20, Color.RGB(237, 207, 59));
  GUI.DrawTextEx(FONT, "4 - Spawn INTEGER block", cwin.absolute_position.x+5, cwin.absolute_position.y+65, 20, Color.RGB(252, 162, 45));
  GUI.DrawTextEx(FONT, "5 - Spawn DIV block", cwin.absolute_position.x+5, cwin.absolute_position.y+85, 20, Color.RGB(237, 207, 59));
  GUI.DrawTextEx(FONT, "6 - Spawn MUL block", cwin.absolute_position.x+5, cwin.absolute_position.y+105, 20, Color.RGB(237, 207, 59));
  GUI.DrawTextEx(FONT, "7 - Spawn COLOR block", cwin.absolute_position.x+5, cwin.absolute_position.y+125, 20, Color.RGB(174, 140, 219));
  GUI.DrawTextEx(FONT, "8 - Spawn VECTOR2 block", cwin.absolute_position.x+5, cwin.absolute_position.y+145, 20, Color.RGB(41, 141, 229));
  GUI.DrawTextEx(FONT, "9 - Spawn RECTANGLE block", cwin.absolute_position.x+5, cwin.absolute_position.y+165, 20, Color.RGB(81, 232, 161));
  GUI.DrawTextEx(FONT, "0 - Spawn STRING block", cwin.absolute_position.x+5, cwin.absolute_position.y+185, 20, Color.RGB(252, 233, 90));
  GUI.DrawTextEx(FONT, "A - Spawn CIRCLE block", cwin.absolute_position.x+5, cwin.absolute_position.y+205, 20, Color.RGB(117, 168, 216));
  GUI.DrawTextEx(FONT, "B - Spawn TRIANGLE block", cwin.absolute_position.x+5, cwin.absolute_position.y+225, 20, Color.RGB(117, 168, 216));
  GUI.DrawTextEx(FONT, "Q - Deselect block", cwin.absolute_position.x+5, cwin.absolute_position.y+245, 20, rl.WHITE);
end

local function DrawRunner()
  local cwin = child_windows.runner;
  GUI.DrawBackground(cwin.absolute_position.x, cwin.absolute_position.y, cwin.w, cwin.h, rl.WHITE);
  DrawGrid(cwin, Color.RGB(240, 245, 250));
  GUI.DrawTextEx(FONT, "Press Q to return", 5, 5, 16, rl.BLACK);
  for _, item in ipairs(Executor.ExecutionList) do
    if (item.what == "text") then
      cwin:DrawText(item.content, item.style.position.x, item.style.position.y, 15, item.style.color);
    elseif (item.what == "rectangle") then
      if (item.style.rotation ~= 0) then
        cwin:DrawRotatedBackground(
            item.style.position.x,
            item.style.position.y,
            item.style.size.x,
            item.style.size.y,
            item.style.size.x/2,
            item.style.size.y/2,
            item.style.rotation,
            item.style.color
          );
      else
        cwin:DrawBackground(item.style.position.x-item.style.size.x/2, item.style.position.y-item.style.size.y/2, item.style.size.x, item.style.size.y, item.style.color);
      end
    elseif (item.what == "triangle") then
    cwin:DrawTriangle(item.vertex.a, item.vertex.b, item.vertex.c, item.style.color);
    elseif (item.what == "circle") then
      cwin:DrawCircle(item.style.position.x-item.style.radius, item.style.position.y-item.style.radius, item.style.radius, item.style.color);
    end
  end
end

local function DrawToolbar()
  local cwin = child_windows.toolbar;
  local focused = false;
  cwin:DrawBackground(0, 0, cwin.w, cwin.h, Color.RGB(14, 15, 17));
  if (cwin:IsMouseHover(5, 5, 50, 20, mouse.x, mouse.y) and rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) then
    current_scene = allScenes["running"];
    child_windows.runner.x = 0;
    child_windows.runner.y = 0;
    child_windows.runner.zoom = 1;
    for i = 1, #Executor.ExecutionList do
      Executor.ExecutionList[i] = nil;
    end
    for _, block in pairs(global_box.all) do
      if (block.type == GBlock.types.DISPLAY or block.type == GBlock.types.RECTANGLE or block.type == GBlock.types.CIRCLE or block.type == GBlock.types.TRIANGLE) then
        Executor.ExecuteBlock(global_box.all, block);
      end
    end
  end
  cwin:DrawTextEx(FONT, "RUN", 10, 4, 22, rl.WHITE);
  cwin:DrawTextEx(FONT, "CODE", 54, 4, 22, rl.WHITE);
end

local function MouseUpdate()
  local mouse_scroll_dt = rl.GetMouseWheelMove();
  local mouse_dt = rl.new("Vector2", mouse.x-prev_mouse.x, mouse.y-prev_mouse.y);
  for cwin_name, cwin in pairs(child_windows) do
    if (GUI.IsMouseHover(cwin.absolute_position.x, cwin.absolute_position.y, cwin.w, cwin.h, mouse.x, mouse.y)) then
      if (current_scene == allScenes["default"] and cwin_name == "editor") then
        if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) then
          right_click_menu.activated = true;
          right_click_menu.where.x = mouse.x;
          right_click_menu.where.y = mouse.y;
        end
        cwin.zoom = math.max(0.5, math.min(cwin.zoom + mouse_scroll_dt*0.25, 3));
        if (selecting_block.what ~= "dragging" and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) then
          cwin.x = cwin.x + 0.7*mouse_dt.x*(1/cwin.zoom);
          cwin.y = cwin.y + 0.7*mouse_dt.y*(1/cwin.zoom);
        end
      elseif (current_scene == allScenes["running"] and cwin_name == "runner") then
        cwin.zoom = math.max(0.5, math.min(cwin.zoom + mouse_scroll_dt*0.25, 3));
        if (selecting_block.what ~= "dragging" and rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) then
          cwin.x = cwin.x + 0.7*mouse_dt.x*(1/cwin.zoom);
          cwin.y = cwin.y + 0.7*mouse_dt.y*(1/cwin.zoom);
        end
      end
    end
  end
  prev_mouse.x = mouse.x;
  prev_mouse.y = mouse.y;
end

local function BufferUpdate()
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
      global_box.all[selecting_block.id].Value = translateToNumber and tostring(translateToNumber) or "0";
      selecting_block.id = -1;
      typingBuffer.size = 0;
      typingBuffer.value = "";
    end
    -- print(typingBuffer.value, typingBuffer.size);
  elseif (selecting_block.what == "typing-string") then
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
      global_box.all[selecting_block.id].Value = typingBuffer.value;
      selecting_block.id = -1;
      typingBuffer.size = 0;
      typingBuffer.value = "";
    end
  end
end

local function Update()
  rl.BeginDrawing();
  rl.ClearBackground(rl.BLACK);
  if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) then
    if (selecting_block.what == "dragging") then
      selecting_block.id = -1;
      selecting_block.what = "";
    end
  end
  MouseUpdate();
  if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and selecting_block.what == "dragging") then
    -- Top panel of block, for dragging
    local block = global_box.all[selecting_block.id];
    local drag_dt_x = (child_windows.editor:TrasnlateFromViewportXToScreenX(block.x)-mouse.x/GUI.scale_ratio.w)/child_windows.editor.zoom;
    local drag_dt_y = (child_windows.editor:TranslateFromViewportYToScreenY(block.y)-mouse.y/GUI.scale_ratio.h)/child_windows.editor.zoom;
    global_box.all[selecting_block.id].x = block.x - drag_dt_x - GBlock.block_graphical_data[block.type].title[3]/2;
    global_box.all[selecting_block.id].y = block.y - drag_dt_y - GBlock.block_graphical_data[block.type].title[4]/2;
  end
  if (rl.IsKeyPressed(rl.KEY_F2)) then
    display_fps = not display_fps;
  end
  if (rl.IsKeyPressed(rl.KEY_Q)) then
    if (current_scene == allScenes.default and selecting_block.what ~= "dragging") then
      selecting_block.id = -1;
      selecting_block.what = "";
    elseif (current_scene == allScenes.running) then
      selecting_block.id = -1;
      selecting_block.what = "";
      current_scene = allScenes.default;
    end
  end
  BufferUpdate();
  if (current_scene == allScenes.default and selecting_block.what == "" or selecting_block.what == "dragging") then
    if (rl.IsKeyPressed(rl.KEY_ONE)) then
      SpawnNewBlock(GBlock.types.DISPLAY);
    elseif (rl.IsKeyPressed(rl.KEY_TWO)) then
      SpawnNewBlock(GBlock.types.ADD)
    elseif (rl.IsKeyPressed(rl.KEY_THREE)) then
      SpawnNewBlock(GBlock.types.SUB)
    elseif (rl.IsKeyPressed(rl.KEY_FOUR)) then
      local block_id = SpawnNewBlock(GBlock.types["GET.INT"])
      global_box.all[block_id].Value = "0";
    elseif (rl.IsKeyPressed(rl.KEY_FIVE)) then
      SpawnNewBlock(GBlock.types.DIV);
    elseif (rl.IsKeyPressed(rl.KEY_SIX)) then
      SpawnNewBlock(GBlock.types.MUL);
    elseif (rl.IsKeyPressed(rl.KEY_SEVEN)) then
      SpawnNewBlock(GBlock.types.COLOR);
    elseif (rl.IsKeyPressed(rl.KEY_EIGHT)) then
      SpawnNewBlock(GBlock.types.VECTOR2);
    elseif (rl.IsKeyPressed(rl.KEY_NINE)) then
      SpawnNewBlock(GBlock.types.RECTANGLE);
    elseif (rl.IsKeyPressed(rl.KEY_ZERO)) then
      local block_id = SpawnNewBlock(GBlock.types["GET.STR"])
      global_box.all[block_id].Value = "Hi kogse!";
    elseif (rl.IsKeyPressed(rl.KEY_A)) then
      SpawnNewBlock(GBlock.types.CIRCLE);
    elseif (rl.IsKeyPressed(rl.KEY_B)) then
      SpawnNewBlock(GBlock.types.TRIANGLE);
    end
  end
  if (current_scene == allScenes.default) then
    local loadOrder = {"editor", "toolbar"};
    for _, cwin_name in ipairs(loadOrder) do
      local cwin = child_windows[cwin_name];
      -- print(cwin_name);
      if (cwin_name == "editor") then
        DrawEditor();
      elseif (cwin_name == "toolbar") then
        DrawToolbar();
      end
    end
  elseif (current_scene == allScenes["running"]) then
    DrawRunner();
  end
  if (display_fps) then
    rl.DrawFPS(10, 10);
  end
  rl.EndDrawing();
end

-- No need to modify those code below
rl.SetConfigFlags(bit.bor(rl.FLAG_VSYNC_HINT, rl.FLAG_WINDOW_RESIZABLE, rl.FLAG_WINDOW_MAXIMIZED, 0));
rl.InitWindow(window.w, window.h, window.title);
rl.SetTargetFPS(config.max_fps);
FONT = rl.LoadFontEx("resources/JetBrainsMono-SemiBold.ttf", 128, nil, 0);
rl.SetTextureFilter(FONT.texture, rl.TEXTURE_FILTER_BILINEAR);
rl.SetExitKey(rl.KEY_NULL);
while not rl.WindowShouldClose() do
  GUI.Update(Update);
end
rl.CloseWindow();