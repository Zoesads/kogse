---@alias PORT_t {connected_to: string, des: string, __parity: boolean}
---@alias BLOCK_t {x: number, y: number, type: integer, Value: nil | string, I1: nil | PORT_t, I2: nil | PORT_t, I3: nil | PORT_t, O: nil | PORT_t};

local Color = require("color");
local KogseGraphicalBlock = {};
---@type table<string, integer>
KogseGraphicalBlock.types = {
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
};
---@type table<number, string[]>
KogseGraphicalBlock.available_ports = {
  [KogseGraphicalBlock.types["GET.STR"]] = {"O"};
  [KogseGraphicalBlock.types["GET.INT"]] = {"O"};
  [KogseGraphicalBlock.types.ADD] = {"I1", "I2", "O"};
  [KogseGraphicalBlock.types.SUB] = {"I1", "I2", "O"};
  [KogseGraphicalBlock.types.MUL] = {"I1", "I2", "O"};
  [KogseGraphicalBlock.types.DIV] = {"I1", "I2", "O"};
  [KogseGraphicalBlock.types.DISPLAY] = {"I1", "I2", "I3"};
  [KogseGraphicalBlock.types.VECTOR2] = {"I1", "I2", "O"};
  [KogseGraphicalBlock.types.COLOR] = {"I1", "I2", "I3", "O"};
  [KogseGraphicalBlock.types.RECTANGLE] = {"I1", "I2", "I3", "I4"};
  [KogseGraphicalBlock.types.CIRCLE] = {"I1", "I2", "I3"};
  [KogseGraphicalBlock.types.TRIANGLE] = {"I1", "I2", "I3", "I4"};
};
KogseGraphicalBlock.block_graphical_data = {
  [KogseGraphicalBlock.types["GET.STR"]] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 40};
    input = {5, 28, 70, 16};
    ports = {
      O = {88, 30, 5}
    }
  };
  [KogseGraphicalBlock.types["GET.INT"]] = {
    title = {0, 0, 100, 15};
    close_btt = {90, 0, 15, 15};
    background = {0, 15, 100, 40};
    input = {5, 28, 70, 16};
    ports = {
      O = {88, 30, 5}
    }
  };
  [KogseGraphicalBlock.types.VECTOR2] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGraphicalBlock.types.ADD] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGraphicalBlock.types.SUB] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGraphicalBlock.types.MUL] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGraphicalBlock.types.DIV] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 55};
    ports = {
      O = {70, 35, 5};
      I1 = {2, 25, 5};
      I2 = {2, 50, 5};
    }
  };
  [KogseGraphicalBlock.types.DISPLAY] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 65};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
    }
  };
  [KogseGraphicalBlock.types.RECTANGLE] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 85};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
    }
  };
  [KogseGraphicalBlock.types.CIRCLE] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 65};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
    }
  };
  [KogseGraphicalBlock.types.TRIANGLE] = {
    title = {0, 0, 80, 15};
    close_btt = {70, 0, 15, 15};
    background = {0, 15, 80, 85};
    ports = {
      I1 = {2, 20, 5};
      I2 = {2, 40, 5};
      I3 = {2, 60, 5};
      I4 = {2, 80, 5};
    }
  };
  [KogseGraphicalBlock.types.COLOR] = {
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
function KogseGraphicalBlock.GetPortDisplayPosition(block, port_name)
  assert(type(block.type) == "number"and
         KogseGraphicalBlock.available_ports[block.type] and
         KogseGraphicalBlock.block_graphical_data[block.type].ports[port_name], "Unable to get port's position to display it (" .. tostring(block.type) .. ", " .. port_name .. ")");
  local res = KogseGraphicalBlock.block_graphical_data[block.type].ports[port_name];
  return {
    x = block.x + res[1] + res[3]/2;
    y = block.y + res[2] + res[3]/2;
  };
end
---@param block_type integer
---@return string[] | nil
function KogseGraphicalBlock.GetBlockPorts(block_type)
  assert(type(KogseGraphicalBlock.available_ports[block_type]) == "table", "no port available");
  return KogseGraphicalBlock.available_ports[block_type];
end

---@param block_type integer
---@param port_name string
---@return boolean
function KogseGraphicalBlock.IsValidPort(block_type, port_name)
  if (not KogseGraphicalBlock.available_ports[block_type]) then
      return false;
  end
  for _, v in ipairs(KogseGraphicalBlock.GetBlockPorts(block_type)) do
    if (v == port_name) then
      return true;
    end
  end
  return false;
end

function KogseGraphicalBlock.CreateBox()
  local box = {};
  local box_index_counter = 0;

  ---@type table<integer, BLOCK_t>
  box.all = {};

  ---@param type integer
  ---@param xpos number
  ---@param ypos number
  ---@return integer
  function box.NewBlock(type, xpos, ypos)
    local block = {
      x = xpos;
      y = ypos;
      type = type;
    };
    for _, port in ipairs(KogseGraphicalBlock.GetBlockPorts(type)) do
      block[port] = {
        connected_to = "";
        des = "";
        __parity = true;
      };
    end
    box_index_counter = box_index_counter + 1;
    box.all[box_index_counter] = block;
    return box_index_counter;
  end

  ---@param block_id integer
  ---@return nil
  function box.DeleteBlock(block_id)
    local block = box.all[block_id];
    for _, port in ipairs(KogseGraphicalBlock.GetBlockPorts(block.type)) do
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
    if (not KogseGraphicalBlock.IsValidPort(A.type, loc) or not KogseGraphicalBlock.IsValidPort(B.type, des)) then
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
      __parity = true;
    };
    box.all[block_des_index][des] = {
      connected_to = block_src_index;
      des = loc;
      __parity = true;
    };
    return true;
  end
  return box;
end


return KogseGraphicalBlock