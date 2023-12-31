local GBlock = require("gblock");
local Color = require("color");
local KogseExec = {};
local Target = "init";
local Datatypes = {
  ["any"] = 0;
  ["Number"] = 1;
  ["String"] = 2;
  ["Vector2"] = 3;
  ["Color"] = 4;
};
KogseExec.Definitions = {};
KogseExec.ExecutionList = {
  init = {};
  on_click = {};
  update = {};
};

---@param _type integer
---@param _value any
local function KEXC_RESULT(_type, _value)
  return {
    type = _type;
    value = _value;
  };
end

function KogseExec.Clear()
  KogseExec.Definitions = {};
  for list_name, list_content in pairs(KogseExec.ExecutionList) do
    KogseExec.ExecutionList[list_name] = {};
  end
end

---@param exc_type string
function KogseExec.SetExecutionTarget(exc_type)
  if (exc_type == "onload") then
    Target = "init";
  elseif (exc_type == "onupdate") then
    Target = "update";
  elseif (exc_type == "onclick") then
    Target = "on_click";
  end
end

---@type table<number, fun(box_which_block_is_in: table<number, BLOCK_t>, block: BLOCK_t): nil | table>
KogseExec.Executor = {
  [GBlock.types["GET.INT"]] = function(box_which_block_is_in, block)
    local res = type(block.Value) == "string" and tonumber(block.Value) or 0;
    return KEXC_RESULT(Datatypes.Number, (res or 0));
  end;
  [GBlock.types["GET.STR"]] = function(box_which_block_is_in, block)
    local res = type(block.Value) == "string" and block.Value or "";
    return KEXC_RESULT(Datatypes.String, res);
  end;
  [GBlock.types["GET.DEFINITION"]] = function(box_which_block_is_in, block)
    local res = type(block.Value) == "string" and block.Value or "";
    if (KogseExec.Definitions[res]) then
      return KogseExec.Definitions[res];
    end
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.DEFINE] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    if (args[1].type == Datatypes.String) then
      KogseExec.Definitions[args[1].value] = args[2];
    end
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.VECTOR2] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    return KEXC_RESULT(Datatypes.Vector2, rl.new("Vector2",
        args[1].type == Datatypes.Number and args[1].value or 0,
        args[2].type == Datatypes.Number and args[2].value or 0
      ));
  end;
  [GBlock.types.ADD] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    if (args[1].type == Datatypes.Vector2) then
      if (args[2].type == Datatypes.Vector2) then
        return KEXC_RESULT(Datatypes.Vector2, rl.new("Vector2", args[1].value.x+args[2].value.x, args[1].value.y + args[2].value.y));
      elseif (args[2].type == Datatypes.any) then
        return args[1];
      end
      return KEXC_RESULT(Datatypes.any, 0);
    elseif (args[2].type == Datatypes.Vector2) then
      return args[2];
    elseif (args[1].type == Datatypes.Number and args[2].type == Datatypes.Number) then
      return KEXC_RESULT(Datatypes.Number, args[1].value + args[2].value);
    else
      return KEXC_RESULT(Datatypes.any, 0);
    end
  end;
  [GBlock.types.SUB] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    if (args[1].type == Datatypes.Vector2) then
      if (args[2].type == Datatypes.Vector2) then
        return KEXC_RESULT(Datatypes.Vector2, rl.new("Vector2", args[1].value.x-args[2].value.x, args[1].value.y-args[2].value.y));
      elseif (args[2].type == Datatypes.any) then
        return args[1];
      end
      return KEXC_RESULT(Datatypes.any, 0); 
    elseif (args[2].type == Datatypes.Vector2) then
      return args[2];
    elseif (args[1].type == Datatypes.Number and args[2].type == Datatypes.Number) then
      return KEXC_RESULT(Datatypes.Number, args[1].value - args[2].value);
    else
      return KEXC_RESULT(Datatypes.any, 0);
    end
  end;
  [GBlock.types.MUL] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    if (args[1].type == Datatypes.Number) then
      if (args[2].type == Datatypes.Number) then
        return KEXC_RESULT(Datatypes.Number, args[1].value * args[2].value);
      elseif (args[2].type == Datatypes.Vector2) then
        return KEXC_RESULT(Datatypes.Vector2, rl.new("Vector2", args[2].value.x*args[1].value, args[2].value.y*args[1].value));
      end
      return KEXC_RESULT(Datatypes.any, 0);
    elseif (args[2].type == Datatypes.Number) then
      if (args[1].type == Datatypes.Number) then
        return KEXC_RESULT(Datatypes.Number, args[1].value * args[2].value);
      elseif (args[1].type == Datatypes.Vector2) then
        return KEXC_RESULT(Datatypes.Vector2, rl.new("Vector2", args[1].value.x*args[2].value, args[1].value.y*args[2].value));
      end
      return KEXC_RESULT(Datatypes.any, 0);
    else
      return KEXC_RESULT(Datatypes.any, 0);
    end
  end;
  [GBlock.types.DIV] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    if (args[1].type == Datatypes.Number and args[2].type == Datatypes.Number and args[2].value ~= 0) then
      return KEXC_RESULT(Datatypes.Number, args[1].value / args[2].value);
    else
      return KEXC_RESULT(Datatypes.any, 0);
    end
  end;
  [GBlock.types.COLOR] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    return KEXC_RESULT(Datatypes.Color, Color.RGB(
        args[1].type == Datatypes.Number and args[1].value or 0,
        args[2].type == Datatypes.Number and args[2].value or 0,
        args[3].type == Datatypes.Number and args[3].value or 0
      ));
  end;
  [GBlock.types.DISPLAY] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    table.insert(KogseExec.ExecutionList[Target], {
      what = "text";
      content = ((args[1].type == Datatypes.Number or args[1].type == Datatypes.String) and tostring(args[1].value) or "");
      style = {
        position = args[2].type == Datatypes.Vector2 and args[2].value or rl.new("Vector2", 0, 0);
        color = args[3].type == Datatypes.Color and args[3].value or Color.RGB(0, 0, 0);
      };
    });
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.RECTANGLE] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    table.insert(KogseExec.ExecutionList[Target], {
      what = "rectangle";
      style = {
        size = args[1].type == Datatypes.Vector2 and args[1].value or rl.new("Vector2", 10, 10);
        position = args[2].type == Datatypes.Vector2 and args[2].value or rl.new("Vector2", 0, 0);
        color = args[3].type == Datatypes.Color and args[3].value or Color.RGB(0, 0, 0);
        rotation = args[4].type == Datatypes.Number and args[4].value or 0;
      };
    });
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.STAR] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    local size = args[1].type == Datatypes.Number and args[1].value or 5;
    local pos = args[2].type == Datatypes.Vector2 and args[2].value or rl.new("Vector2", 0, 0);
    local rotation = (args[4].type == Datatypes.Number and args[4].value or 0) * math.pi/180;
    local verticies = {};
    local centroid_x = 0;
    local centroid_y = 0;
    for i = 1, 5 do
      local vert_x = pos.x + size*math.cos(2/5*math.pi*i-math.pi/2-rotation);
      local vert_y = pos.y + size*math.sin(2/5*math.pi*i-math.pi/2-rotation);
      table.insert(verticies, rl.new("Vector2", vert_x, vert_y));
      centroid_x = centroid_x + vert_x;
      centroid_y = centroid_y + vert_y;
    end
    centroid_x = centroid_x/5;
    centroid_y = centroid_y/5;
    local centroid = rl.new("Vector2", centroid_x, centroid_y);
    local small_triangles = {};
    for i = 1, 3 do
      table.insert(small_triangles, {verticies[i], centroid, verticies[i+2]});
      if (i+3 <= 5) then
        table.insert(small_triangles, {verticies[i], centroid, verticies[i+3]});
      end
    end
    for i = 1, #small_triangles do
      local small_triangle_centroid = rl.new("Vector2",
          (small_triangles[i][1].x + small_triangles[i][2].x + small_triangles[i][3].x)/3,
          (small_triangles[i][1].y + small_triangles[i][2].y + small_triangles[i][3].y)/3
        );
      table.sort(small_triangles[i], function(a,b)
        local A = (math.deg(math.atan2(a.x-small_triangle_centroid.x, a.y-small_triangle_centroid.y))+360)%360;
        local B = (math.deg(math.atan2(b.x-small_triangle_centroid.x, b.y-small_triangle_centroid.y))+360)%360;
        return A < B;
      end);
    end
    table.insert(KogseExec.ExecutionList[Target], {
      what = "star";
      polygon = small_triangles;
      style = {
        color = args[3].type == Datatypes.Color and args[3].value or Color.RGB(0, 0, 0);
      };
    });
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.TRIANGLE] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    local vertex_fixed = {
      args[1].type == Datatypes.Vector2 and args[1].value or rl.new("Vector2", 0, 0),
      args[2].type == Datatypes.Vector2 and args[2].value or rl.new("Vector2", 0, 0),
      args[3].type == Datatypes.Vector2 and args[3].value or rl.new("Vector2", 0, 0)
    };
    local center = rl.new("Vector2", (vertex_fixed[1].x + vertex_fixed[2].x + vertex_fixed[3].x)/3, (vertex_fixed[1].y + vertex_fixed[2].y + vertex_fixed[3].y)/3)
    table.sort(vertex_fixed, function(a,b)
      local A = (math.deg(math.atan2(a.x-center.x, a.y-center.y))+360)%360;
      local B = (math.deg(math.atan2(b.x-center.x, b.y-center.y))+360)%360;
      return A < B;
    end)
    table.insert(KogseExec.ExecutionList[Target], {
      what = "triangle";
      vertex = {
        a = vertex_fixed[1];
        b = vertex_fixed[2];
        c = vertex_fixed[3];
      };
      style = {
        color = args[4].type == Datatypes.Color and args[4].value or Color.RGB(0, 0, 0);
      };
    });
    return KEXC_RESULT(Datatypes.any, 0);
  end;
  [GBlock.types.CIRCLE] = function(box_which_block_is_in, block)
    local args = {};
    local argc = 0;
    for _, port_name in ipairs(GBlock.GetBlockPorts(block.type)) do
      if (port_name ~= "O") then
        local des_block = box_which_block_is_in[block[port_name].connected_to];
        argc = argc + 1;
        if (not des_block) then
          args[argc] = KEXC_RESULT(Datatypes.any, 0);
        else
          args[argc] = KogseExec.ExecuteBlock(box_which_block_is_in, des_block);
        end
      end
    end
    table.insert(KogseExec.ExecutionList[Target], {
      what = "circle";
      style = {
        radius = args[1].type == Datatypes.Number and args[1].value or 10;
        position = args[2].type == Datatypes.Vector2 and args[2].value or rl.new("Vector2", 0, 0);
        color = args[3].type == Datatypes.Color and args[3].value or Color.RGB(0, 0, 0);
      };
    });
    return KEXC_RESULT(Datatypes.any, 0);
  end;
};
---@param box_which_block_is_in table
---@param block BLOCK_t
---@return table | nil
function KogseExec.ExecuteBlock(box_which_block_is_in, block)
  local exc_func = KogseExec.Executor[block.type];
  if (type(exc_func) == "function") then
    return exc_func(box_which_block_is_in, block);
  end
  return nil;
end

return KogseExec;