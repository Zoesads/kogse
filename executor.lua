local GBlock = require("gblock");
local Color = require("color");
local KogseExec = {};
local Datatypes = {
  ["any"] = 0;
  ["Number"] = 1;
  ["String"] = 2;
  ["Vector2"] = 3;
  ["Color"] = 4;
};
KogseExec.ExecutionList = {};

---@param _type integer
---@param _value any
local function KEXC_RESULT(_type, _value)
  return {
    type = _type;
    value = _value;
  };
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
    table.insert(KogseExec.ExecutionList, {
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
    table.insert(KogseExec.ExecutionList, {
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
    table.insert(KogseExec.ExecutionList, {
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
    table.insert(KogseExec.ExecutionList, {
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