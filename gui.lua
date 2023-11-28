local GUI = {};

---@param width number window's width
---@param height number window's height
---@param title string window's title
---@param maximum_fps integer maximum fps
function GUI.Init(width, height, title, maximum_fps)
  GUI.window = {
    w = width;
    h = height;
    title = title;
  };
  GUI.scale_ratio = {
    w = 1;
    h = 1;
  }
  GUI.config = {
    max_fps = maximum_fps or 60;
  };
  GUI.time = {previous = 0.0; now = 0.0; delta = 0.0;};
  GUI.mouse = rl.new("Vector2", 0, 0);
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param color Color | nil
---@return nil
function GUI.DrawBackground(x, y, w, h, color)
  rl.DrawRectangle(x*GUI.scale_ratio.w, y*GUI.scale_ratio.h, w*GUI.scale_ratio.w, h*GUI.scale_ratio.h, color or rl.PURPLE);
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param r number
---@param color Color | nil
---@return nil
function GUI.DrawRoundedBackground(x, y, w, h, r, color)
  rl.DrawRectangleRounded({x*GUI.scale_ratio.w, y*GUI.scale_ratio.h, w*GUI.scale_ratio.w, h*GUI.scale_ratio.h}, math.min(1, math.max(0, r)), 3, color or rl.PURPLE);
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param ox number
---@param oy number
---@param rotation number
---@param color Color | nil
---@return nil
function GUI.DrawRotatedBackground(x, y, w, h, ox, oy, rotation, color)
  rl.DrawRectanglePro({x*GUI.scale_ratio.w, y*GUI.scale_ratio.h, w*GUI.scale_ratio.w, h*GUI.scale_ratio.h}, rl.new("Vector2", ox*GUI.scale_ratio.w, oy*GUI.scale_ratio.h), rotation, color or rl.PURPLE);
end

---@param x number
---@param y number
---@param r number
---@param color Color | nil
---@return nil
function GUI.DrawCircle(x, y, r, color)
  local radius = r*math.max(GUI.scale_ratio.w,GUI.scale_ratio.h)
  rl.DrawCircle(x*GUI.scale_ratio.w + radius, y*GUI.scale_ratio.h + radius, radius, color or rl.PURPLE);
end

---@param text string
---@param x number
---@param y number
---@param font_size number
---@param color Color | nil
---@return nil
function GUI.DrawText(text, x, y, font_size, color)
  rl.DrawText(text, x*GUI.scale_ratio.w, y*GUI.scale_ratio.h, font_size*math.max(GUI.scale_ratio.w, GUI.scale_ratio.h), color or rl.BLACK);
end

---@param font Font
---@param text string
---@param x number
---@param y number
---@param font_size number
---@param color Color | nil
---@return nil
function GUI.DrawTextEx(font, text, x, y, font_size, color)
  rl.DrawTextEx(font, text, rl.new("Vector2", x*GUI.scale_ratio.w, y*GUI.scale_ratio.h), font_size*math.max(GUI.scale_ratio.w, GUI.scale_ratio.h), 2, color or rl.BLACK);
end

---@param startp Vector2
---@param endp Vector2
---@param thickness number
---@param color Color
function GUI.DrawBezierCurve(startp, endp, thickness, color)
  rl.DrawLineBezier({startp.x*GUI.scale_ratio.w or 0, startp.y*GUI.scale_ratio.h or 0}, {endp.x*GUI.scale_ratio.w or 0, endp.y*GUI.scale_ratio.h or 0}, thickness*math.max(GUI.scale_ratio.w, GUI.scale_ratio.h) or 1, color or rl.PURPLE);
end

---@param A Vector2
---@param B Vector2
---@param C Vector2
---@param color Color
function GUI.DrawTriangle(A, B, C, color)
  rl.DrawTriangle(rl.new("Vector2", A.x*GUI.scale_ratio.w, A.y*GUI.scale_ratio.h), 
                  rl.new("Vector2", B.x*GUI.scale_ratio.w, B.y*GUI.scale_ratio.h), 
                  rl.new("Vector2", C.x*GUI.scale_ratio.w, C.y*GUI.scale_ratio.h),
                  color);
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
function GUI.AABB(a_x, a_y, a_w, a_h, b_x, b_y, b_w, b_h)
  return (a_x + a_w) >= (b_x) and (b_x + b_w) >= (a_x) and
         (a_y + a_h) >= (b_y) and (b_y + b_h) >= (a_y);
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param mouse_x number
---@param mouse_y number
---@return boolean
function GUI.IsMouseHover(x, y, w, h, mouse_x, mouse_y)
  return GUI.AABB(x*GUI.scale_ratio.w, y*GUI.scale_ratio.h, w*GUI.scale_ratio.w, h*GUI.scale_ratio.h, mouse_x, mouse_y, 5, 5);
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param style {color: {clicked: Color | nil, hovered: Color | nil, idle: Color | nil}, roundness: number| nil}
---@param event_fn {on_click: fun()}
function GUI.Button(x, y, w, h, style, event_fn)
  local is_hovered = GUI.IsMouseHover(x, y, w, h, GUI.mouse.x, GUI.mouse.y);
  local is_clicked = is_hovered and rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT);
  local color_chosen = style.color.idle;
  if (is_clicked) then
    color_chosen = style.color.clicked or style.color.idle;
  elseif (is_hovered) then
    color_chosen = style.color.hovered or style.color.idle;
  else
    color_chosen = style.color.idle;
  end
  color_chosen = color_chosen or rl.PURPLE;
  GUI.DrawRoundedBackground(x, y, w, h, style.roundness or 0, color_chosen);
  if (is_clicked and type(event_fn)=="table" and type(event_fn.on_click) == "function") then
    event_fn.on_click();
  end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param style {color: {clicked: Color | nil, hovered: Color | nil, idle: Color | nil}, roundness: number| nil, direction: string}
---@param buttons table
---@param event_fn {on_hover: fun()}
function GUI.ExpandMenu(x, y, w, h, style, buttons, event_fn)
  local is_hovered = GUI.IsMouseHover(x, y, w, h, GUI.mouse.x, GUI.mouse.y);
  local color_chosen = style.color.idle;
  if (is_hovered) then
    color_chosen = style.color.hovered or style.color.idle;
  else
    color_chosen = style.color.idle;
  end
  color_chosen = color_chosen or rl.PURPLE;
  if (is_hovered) then

    if (type(event_fn) == "table" and type(event_fn.on_hover) == "function") then
      event_fn.on_hover();
    end
  end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param style {color: {hovered: Color | nil, idle: Color | nil}, roundness: number| nil}
function GUI.Menu(title, x, y, w, h, style, buttons)
  local is_hovered = GUI.IsMouseHover(x, y, w, h, GUI.mouse.x, GUI.mouse.y);
  local color_chosen = style.color.idle;
  if (is_hovered) then
    color_chosen = style.color.hovered or style.color.idle;
  else
    color_chosen = style.color.idle;
  end
  color_chosen = color_chosen or rl.PURPLE;
end

---@param update_func function
---@return nil
function GUI.Update(update_func)
  do
    ---@type Vector2
    local newMousePosition = rl.GetMousePosition();
    GUI.mouse.x = newMousePosition.x;
    GUI.mouse.y = newMousePosition.y;
  end
  do
    local actualWidth = rl.GetScreenWidth();
    local actualHeight = rl.GetScreenHeight();
    GUI.scale_ratio.w = actualWidth/GUI.window.w;
    GUI.scale_ratio.h = actualHeight/GUI.window.h
  end
  do
    GUI.time.now = rl.GetTime();
    local updateTime = GUI.time.now - GUI.time.previous;
    local waitTime = 1.0/GUI.config.max_fps - updateTime;
    if (waitTime > 0) then
      rl.WaitTime(waitTime);
      GUI.time.now = rl.GetTime();
      GUI.time.delta = GUI.time.now-GUI.time.previous;
    end
    GUI.time.previous = GUI.time.now;
  end
  update_func();
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param ox number | nil
---@param oy number | nil
function GUI.Viewport(x, y, w, h, ox, oy)
  local viewport = {
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
  function viewport:TrasnlateFromViewportXToScreenX(x)
    return (x+self.x)*self.zoom + self.origin.x + self.absolute_position.x;
  end

  ---@param y number
  ---@return number
  function viewport:TranslateFromViewportYToScreenY(y)
    return (y+self.y)*self.zoom + self.origin.y + self.absolute_position.y;
  end

  ---@param vec Vector2
  ---@return Vector2
  function viewport:TransateFromViewportVectorToScreenVector(vec)
    return rl.new("Vector2", self:TrasnlateFromViewportXToScreenX(vec.x), self:TranslateFromViewportYToScreenY(vec.y));
  end

  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param mouse_x number
  ---@param mouse_y number
  ---@return boolean
  function viewport:IsMouseHover(x, y, w, h, mouse_x, mouse_y)
    return GUI.IsMouseHover(self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), w*self.zoom, h*self.zoom, mouse_x, mouse_y);
  end

  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawBackground(x, y, w, h, color)
    GUI.DrawBackground(self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), w*self.zoom, h*self.zoom, color);
  end

  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param r number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawRoundedBackground(x, y, w, h, r, color)
    GUI.DrawRoundedBackground(self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), w*self.zoom, h*self.zoom, r or 0, color or rl.PURPLE);
  end

  ---@param x number
  ---@param y number
  ---@param w number
  ---@param h number
  ---@param ox number
  ---@param oy number
  ---@param rotation number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawRotatedBackground(x, y, w, h, ox, oy, rotation, color)
    GUI.DrawRotatedBackground(self:TrasnlateFromViewportXToScreenX(x),
                         self:TranslateFromViewportYToScreenY(y),
                         w*self.zoom,
                         h*self.zoom,
                          ox*self.zoom, oy*self.zoom, rotation, color or rl.PURPLE);
  end

  ---@param x number
  ---@param y number
  ---@param r number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawCircle(x, y, r, color)
    GUI.DrawCircle(self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), r*self.zoom, color);
  end

  ---@param text string
  ---@param x number
  ---@param y number
  ---@param font_size number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawText(text, x, y, font_size, color)
    GUI.DrawText(text, self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), font_size*self.zoom, color);
  end

  ---@param font Font
  ---@param text string
  ---@param x number
  ---@param y number
  ---@param font_size number
  ---@param color Color | nil
  ---@return nil
  function viewport:DrawTextEx(font, text, x, y, font_size, color)
    GUI.DrawTextEx(font, text, self:TrasnlateFromViewportXToScreenX(x), self:TranslateFromViewportYToScreenY(y), font_size*self.zoom, color);
  end

  ---@param startp Vector2
  ---@param endp Vector2
  ---@param thickness number
  ---@param color Color
  function viewport:DrawBezierCurve(startp, endp, thickness, color)
    GUI.DrawBezierCurve(rl.new("Vector2", self:TrasnlateFromViewportXToScreenX(startp.x), self:TranslateFromViewportYToScreenY(startp.y)),
                        rl.new("Vector2", self:TrasnlateFromViewportXToScreenX(endp.x), self:TranslateFromViewportYToScreenY(endp.y)),
                        thickness*self.zoom,
                        color
                        );
  end

  ---@param A Vector2
  ---@param B Vector2
  ---@param C Vector2
  ---@param color Color
  function viewport:DrawTriangle(A, B, C, color)
    GUI.DrawTriangle(self:TransateFromViewportVectorToScreenVector(A),
                     self:TransateFromViewportVectorToScreenVector(B),
                     self:TransateFromViewportVectorToScreenVector(C),
                    color);
  end


  return viewport;
end

return GUI;