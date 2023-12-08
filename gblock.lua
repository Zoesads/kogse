---@alias PORT_t {connected_to: string, des: string, __parity: boolean}
---@alias BLOCK_t {x: number, y: number, type: integer, Value: nil | string, I1: nil | PORT_t, I2: nil | PORT_t, I3: nil | PORT_t, O: nil | PORT_t};

local Color = require("color");
local KogseGBlock = {};
---@type table<string, integer>
KogseGBlock.types = {
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
  ["CIRCLE"] = 12;
  ["TRIANGLE"] = 13;
  ["EVENT.ONLOAD"] = 14;
  ["EVENT.ONCLICK"] = 15;
  ["EVENT.ONUPDATE"] = 16;
  ["DEFINE"] = 17;
  ["GET.DEFINITION"] = 18;
  ["STAR"] = 19;
};
---@type table<number, string[]>
KogseGBlock.available_ports = {
  [KogseGBlock.types["GET.STR"]] = {"O"};
  [KogseGBlock.types["GET.INT"]] = {"O"};
  [KogseGBlock.types.ADD] = {"I1", "I2", "O"};
  [KogseGBlock.types.SUB] = {"I1", "I2", "O"};
  [KogseGBlock.types.MUL] = {"I1", "I2", "O"};
  [KogseGBlock.types.DIV] = {"I1", "I2", "O"};
  [KogseGBlock.types.DISPLAY] = {"I1", "I2", "I3", "I4", "O"};
  [KogseGBlock.types.VECTOR2] = {"I1", "I2", "O"};
  [KogseGBlock.types.COLOR] = {"I1", "I2", "I3", "O"};
  [KogseGBlock.types.RECTANGLE] = {"I1", "I2", "I3", "I4", "I5", "O"};
  [KogseGBlock.types.CIRCLE] = {"I1", "I2", "I3", "I4", "O"};
  [KogseGBlock.types.TRIANGLE] = {"I1", "I2", "I3", "I4", "I5", "O"};
  [KogseGBlock.types["EVENT.ONLOAD"]] = {"O"};
  [KogseGBlock.types["EVENT.ONCLICK"]] = {"O"};
  [KogseGBlock.types["EVENT.ONUPDATE"]] = {"O"};
  [KogseGBlock.types.DEFINE] = {"I1", "I2", "I3", "O"};
  [KogseGBlock.types["GET.DEFINITION"]] = {"O"};
  [KogseGBlock.types.STAR] = {"I1", "I2", "I3", "I4", "I5", "O"};
};
KogseGBlock.block_graphical_data = {
  [KogseGBlock.types["EVENT.ONLOAD"]] = {
    title = {0, 0, 70, 15};
    close_btt = {60, 0, 15, 15};
    background = {0, 15, 70, 35};
    ports = {
      O = {55, 25, 5}
    }
  };
  [KogseGBlock.types["EVENT.ONCLICK"]] = {
    title = {0, 0, 70, 15};
    close_btt = {60, 0, 15, 15};
    background = {0, 15, 70, 35};
    ports = {
      O = {55, 25, 5}
    }
  };
  [KogseGBlock.types["EVENT.ONUPDATE"]] = {
    title = {0, 0, 70, 15};
    close_btt = {60, 0, 15, 15};
    background = {0, 15, 70, 35};
    ports = {
      O = {55, 25, 5}
    }
  };
  [KogseGBlock.types["GET.STR"]] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 40};
    input = {5, 28, 75, 16};
    ports = {
      O = {88, 30, 5}
    }
  };
  [KogseGBlock.types["GET.INT"]] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 40};
    input = {5, 28, 75, 16};
    ports = {
      O = {88, 30, 5}
    }
  };
  [KogseGBlock.types["GET.DEFINITION"]] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 40};
    input = {5, 28, 75, 16};
    ports = {
      O = {88, 30, 5}
    }
  };
  [KogseGBlock.types.VECTOR2] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.DEFINE] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 65};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
    }
  };
  [KogseGBlock.types.ADD] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.ADD] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.SUB] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.MUL] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.DIV] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGBlock.types.DISPLAY] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 85};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
      O = {85, 50, 5};
    }
  };
  [KogseGBlock.types.STAR] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 105};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
      I5 = {2, 100, 5};
      O = {85, 60, 5};
    }
  };
  [KogseGBlock.types.RECTANGLE] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 105};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
      I5 = {2, 100, 5};
      O = {85, 60, 5};
    }
  };
  [KogseGBlock.types.CIRCLE] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 85};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
      O = {85, 50, 5};
    }
  };
  [KogseGBlock.types.TRIANGLE] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 105};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
      I5 = {2, 100, 5};
      O = {85, 60, 5};
    }
  };
  [KogseGBlock.types.COLOR] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 65};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
    }
  };
};
---@param block BLOCK_t
---@param port_name string
---@return Vector2
function KogseGBlock.GetPortDisplayPosition(block, port_name)
  assert(type(block.type) == "number"and
         KogseGBlock.available_ports[block.type] and
         KogseGBlock.block_graphical_data[block.type].ports[port_name], "Unable to get port's position to display it (" .. tostring(block.type) .. ", " .. port_name .. ")");
  local res = KogseGBlock.block_graphical_data[block.type].ports[port_name];
  return {
    x = block.x + res[1] + res[3]/2;
    y = block.y + res[2] + res[3]/2;
  };
end
---@param block_type integer
---@return string[] | nil
function KogseGBlock.GetBlockPorts(block_type)
  assert(type(KogseGBlock.available_ports[block_type]) == "table", "no port available");
  return KogseGBlock.available_ports[block_type];
end

---@param block_type integer
---@param port_name string
---@return boolean
function KogseGBlock.IsValidPort(block_type, port_name)
  if (not KogseGBlock.available_ports[block_type]) then
      return false;
  end
  for _, v in ipairs(KogseGBlock.GetBlockPorts(block_type)) do
    if (v == port_name) then
      return true;
    end
  end
  return false;
end

function KogseGBlock.CreateBox()
  local box = {};
  local box_index_counter = 0;
  local event_block = {
    ["onload"] = -1;
    ["onupdate"] = -1;
    ["onclick"] = -1;
  };

  ---@type table<integer, BLOCK_t>
  box.all = {};

  ---@param event_type string
  ---@return integer
  function box.GetEventHandler(event_type)
    local ev_block_id = event_block[event_type];
    if (type(ev_block_id) == "number") then
      return ev_block_id;
    end
    return -1;
  end

  ---@param type integer
  ---@param xpos number
  ---@param ypos number
  ---@return integer
  function box.NewBlock(type, xpos, ypos)
    if (
      (type == KogseGBlock.types["EVENT.ONLOAD"] and event_block.onload > -1) or
      (type == KogseGBlock.types["EVENT.ONUPDATE"] and event_block.onupdate > -1) or
      (type == KogseGBlock.types["EVENT.ONCLICK"] and event_block.onclick > -1)
    ) then -- prevent creating more than 1 event block for each event
      return -404;
    end
    local block = {
      x = xpos;
      y = ypos;
      type = type;
    };
    for _, port in ipairs(KogseGBlock.GetBlockPorts(type)) do
      block[port] = {
        connected_to = "";
        des = "";
        __parity = true; -- For rendering purpose only
      };
    end
    box_index_counter = box_index_counter + 1;
    box.all[box_index_counter] = block;
    if (type == KogseGBlock.types["EVENT.ONLOAD"] and event_block.onload == -1) then
      event_block.onload = box_index_counter;
    elseif (type == KogseGBlock.types["EVENT.ONUPDATE"] and event_block.onupdate == -1) then
      event_block.onupdate = box_index_counter;
    elseif (type == KogseGBlock.types["EVENT.ONCLICK"] and event_block.onclick == -1) then
      event_block.onclick = box_index_counter;
    end
    return box_index_counter;
  end

  ---@param block_id integer
  ---@return nil
  function box.DeleteBlock(block_id)
    local block = box.all[block_id];
    local block_type = block.type;
    -- If this block is an event block then erase it from event handler registry
    if (block_type == KogseGBlock.types["EVENT.ONLOAD"] and event_block.onload > -1) then
      event_block.onload = -1;
    elseif (block_type == KogseGBlock.types["EVENT.ONUPDATE"] and event_block.onupdate > -1) then
      event_block.onupdate = -1;
    elseif (block_type == KogseGBlock.types["EVENT.ONCLICK"]) then
      event_block.onclick = -1;
    end
    for _, port in ipairs(KogseGBlock.GetBlockPorts(block_type)) do
      local port_connected_to = block[port].connected_to;
      if (port_connected_to ~= "") then
        box.all[port_connected_to][block[port].des].connected_to = "";
      end
    end
    box.all[block_id] = nil;
  end

  ---@param block_src_index integer
  ---@param block_des_index integer
  ---@param loc string
  ---@param des string
  ---@return boolean
  function box.MakeConnection(block_src_index, block_des_index, loc, des)
    local A = box.all[block_src_index];
    local B = box.all[block_des_index];
    if (not KogseGBlock.IsValidPort(A.type, loc) or not KogseGBlock.IsValidPort(B.type, des)) then
      print("[ERROR]: Not recognized port");
      return false;
    end
    if (A[loc].connected_to ~= "") then
      box.all[A[loc].connected_to][A[loc].des].connected_to = "";
    end
    if (B[des].connected_to ~= "") then
      box.all[B[des].connected_to][B[des].des].connected_to = "";
    end
    box.all[block_src_index][loc] = {
      connected_to = block_des_index;
      des = des;
      __parity = true; -- For rendering purpose only
    };
    box.all[block_des_index][des] = {
      connected_to = block_src_index;
      des = loc;
      __parity = true; -- For rendering purpose only
    };
    return true;
  end
  return box;
end


return KogseGBlock