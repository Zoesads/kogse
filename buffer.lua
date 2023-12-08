local Buffer = {};
local previous_pressed_tick = 0;
local translate_keys = {
  {rl.KEY_ONE, "1"};
  {rl.KEY_TWO, "2"};
  {rl.KEY_THREE, "3"};
  {rl.KEY_FOUR, "4"};
  {rl.KEY_FIVE, "5"};
  {rl.KEY_SIX, "6"};
  {rl.KEY_SEVEN, "7"};
  {rl.KEY_EIGHT, "8"};
  {rl.KEY_NINE, "9"};
  {rl.KEY_ZERO, "0"};
  {rl.KEY_SPACE, " "};
  {rl.KEY_MINUS, {"-", "_"}};
  {rl.KEY_COMMA, {",", "<"}};
  {rl.KEY_SEMICOLON, {";", ":"}};
  {rl.KEY_PERIOD, {".", ">"}};
  {rl.KEY_EQUAL, {"=", "+"}};
};
local translate_key_number_only = {
  {rl.KEY_ONE, "1"};
  {rl.KEY_TWO, "2"};
  {rl.KEY_THREE, "3"};
  {rl.KEY_FOUR, "4"};
  {rl.KEY_FIVE, "5"};
  {rl.KEY_SIX, "6"};
  {rl.KEY_SEVEN, "7"};
  {rl.KEY_EIGHT, "8"};
  {rl.KEY_NINE, "9"};
  {rl.KEY_ZERO, "0"};
  {rl.KEY_MINUS, "-"};
};
Buffer.buf = "";
Buffer.size = 0;
Buffer.capacity = 1024;
Buffer.mode = "number";

function Buffer.Flush()
  Buffer.buf = "";
  Buffer.size = 0;
end

---@param mode string
---@param capacity integer
function Buffer.SetMode(mode, capacity)
  if (mode ~= "string" and mode ~= "number") then
    print("[WARNING]: Unrecognized buffer mode: " .. mode);
    return;
  end
  if (Buffer.mode ~= mode) then
    Buffer.Flush();
    Buffer.mode = mode;
    Buffer.capacity = capacity or 1024;
    previous_pressed_tick = 0;
  end
end

---@param content string
function Buffer.Fill(content)
  local content_size = #content;
  local new_size = content_size + Buffer.size;
  if (new_size > Buffer.capacity) then
    print("[WARNING]: Content size will cause buffer to overflow, increasing buffer capacity (requesting " .. tostring(new_size) .. " bytes)");
    repeat
      Buffer.capacity = Buffer.capacity * 2;
    until new_size > Buffer.capacity;
  end
  Buffer.buf = Buffer.buf .. content;
  Buffer.size = new_size;
end

function Buffer.Update()
  if (Buffer.mode == "string" or Buffer.mode == "number") then
    previous_pressed_tick = previous_pressed_tick + 1;
    if (previous_pressed_tick >= 5) then
      if (rl.IsKeyDown(rl.KEY_BACKSPACE) and Buffer.size > 0) then
        Buffer.size = Buffer.size - 1;
        if (Buffer.size == 0) then
          Buffer.buf = "";
        else
          Buffer.buf = Buffer.buf:sub(1, Buffer.size);
        end
      end
      previous_pressed_tick = 0;
    end
  end
  if (Buffer.mode == "string") then
    -- Translate non alphabet characters
    local isShiftDown = rl.IsKeyDown(rl.KEY_LEFT_SHIFT);
    local key_index = -1;
    for idx, key_data in ipairs(translate_keys) do
      if (rl.IsKeyPressed(key_data[1])) then
        key_index = idx;
      end
    end
    if (key_index > 0 and Buffer.capacity-Buffer.size > 0) then
      if (type(translate_keys[key_index][2]) == "table" and #translate_keys[key_index][2] == 2) then
        Buffer.buf = Buffer.buf .. translate_keys[key_index][2][isShiftDown and 2 or 1];
      else
        Buffer.buf = Buffer.buf .. translate_keys[key_index][2];
      end
      Buffer.size = Buffer.size + 1;
      return;
    end
    local alphabet = "abcdefghijklmnopqrstvuwxyz";
    local pressed_char = "";
    for i = 1, 26 do
      local chr = alphabet:sub(i,i);
      if (rl.IsKeyPressed(rl["KEY_" .. chr:upper()])) then
        pressed_char = chr;
      end
    end
    if (pressed_char ~= "" and Buffer.capacity-Buffer.size > 0) then
      Buffer.buf = Buffer.buf .. (isShiftDown and pressed_char:upper() or pressed_char);
      Buffer.size = Buffer.size + 1;
    end
    return;
  elseif (Buffer.mode == "number") then
    if (rl.IsKeyDown(rl.KEY_BACKSPACE) and Buffer.size > 0) then
      Buffer.size = Buffer.size - 1;
      if (Buffer.size == 0) then
        Buffer.buf = "";
      else
        Buffer.buf = Buffer.buf:sub(1, Buffer.size);
      end
    end
    local key_index = -1;
    for idx, key_data in ipairs(translate_key_number_only) do
      if (rl.IsKeyPressed(key_data[1])) then
        key_index = idx;
      end
    end
    if (key_index > 0 and Buffer.capacity-Buffer.size > 0) then
      Buffer.buf = Buffer.buf .. translate_key_number_only[key_index][2];
      Buffer.size = Buffer.size + 1;
      return;
    end
    return;
  end
  print("[WARNING]: Unable to update buffer, unrecognized mode: " .. Buffer.mode);
end

return Buffer;