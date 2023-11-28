local KogseColor = {};
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return Color
function KogseColor.RGBA(r, g, b, a)
  assert(r>=0 and g>=0 and b>=0 and a>=0, ("[ERROR]: Invalid color combination: (%i, %i, %i, %i)"):format(r, g, b, a));
  return rl.new("Color", math.min(255, r), math.min(255, g), math.min(255, b), math.max(0, math.min(255, a)));
end

---@param r integer
---@param g integer
---@param b integer
---@return Color
function KogseColor.RGB(r, g, b)
  return KogseColor.RGBA(r, g, b, 255);
end

---@param colorFrom Color Base color
---@param colorTo Color Target color
---@param step number
---@return Color
function KogseColor.Lerp(colorFrom, colorTo, step)
  assert(type(step) == "number" and 0 <= step and step <= 1, "[ERROR]: Interpolating step should be in range 0 -> 1 (got " .. tostring(step) .. " instead)");
  return KogseColor.RGBA((1-step)*colorFrom[1] + step*colorTo[1],
                    (1-step)*colorFrom[2] + step*colorTo[2],
                    (1-step)*colorFrom[3] + step*colorTo[3],
                    (1-step)*colorFrom[4] + step*colorTo[4]);
end

return KogseColor;