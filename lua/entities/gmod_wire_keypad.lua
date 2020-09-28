AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")
ENT.PrintName = "Wire Keypad"

if CLIENT then
    hook.Add("PlayerBindPress", "Wire_Keypad", function(ply, bind, pressed)
        if not pressed then return end

        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 65,
            filter = ply
        })

        local ent = tr.Entity
        if not IsValid(ent) or not ent.IsKeypad then return end

        if string.find(bind, "+use", nil, true) then
            local element = ent:GetHoveredElement()
            if not element or not element.click then return end
            element.click(ent)
        end
    end)

    local physical_keypad_commands = {
        [KEY_ENTER] = function(self)
            self:SendCommand(self.Command_Accept)
        end,
        [KEY_PAD_ENTER] = function(self)
            self:SendCommand(self.Command_Accept)
        end,
        [KEY_PAD_MINUS] = function(self)
            self:SendCommand(self.Command_Abort)
        end,
        [KEY_PAD_PLUS] = function(self)
            self:SendCommand(self.Command_Abort)
        end
    }

    for i = KEY_PAD_1, KEY_PAD_9 do
        physical_keypad_commands[i] = function(self)
            self:SendCommand(self.Command_Enter, i - KEY_PAD_1 + 1)
        end
    end

    local last_press = 0
    local enter_strict = CreateConVar("wire_keypad_enter_strict", "0", FCVAR_ARCHIVE, "Only allow the numpad's enter key to be used to accept keypads' input")

    hook.Add("CreateMove", "Wire_Keypad", function(cmd)
        if RealTime() - 0.1 < last_press then return end

        for key, handler in pairs(physical_keypad_commands) do
            if input.WasKeyPressed(key) then
                if enter_strict:GetBool() and key == KEY_ENTER then continue end
                local ply = LocalPlayer()

                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = ply:EyePos() + ply:GetAimVector() * 65,
                    filter = ply
                })

                local ent = tr.Entity
                if not IsValid(ent) or not ent.IsKeypad then return end
                last_press = RealTime()
                handler(ent)

                return
            end
        end
    end)

    -- Avoiding the clutter
    function ENT:CalculateCursorPos()
        local ply = LocalPlayer()
        if not IsValid(ply) then return 0, 0 end

        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 65,
            filter = ply
        })

        if tr.Entity ~= self then return 0, 0 end
        local scale = self.Scale
        local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
        local normal = self:GetForward()
        local intersection = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), pos, normal)
        if not intersection then return 0, 0 end
        local diff = pos - intersection
        local x = diff:Dot(-ang:Forward()) / scale
        local y = diff:Dot(-ang:Right()) / scale

        return x, y
    end

    function ENT:CalculateRenderPos()
        local pos = self:GetPos()
        pos:Add(self:GetForward() * self.Maxs.x) -- Translate to front
        pos:Add(self:GetRight() * self.Maxs.y) -- Translate to left
        pos:Add(self:GetUp() * self.Maxs.z) -- Translate to top
        pos:Add(self:GetForward() * 0.15) -- Pop out of front to stop culling

        return pos
    end

    function ENT:CalculateRenderAng()
        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 90)

        return ang
    end

    surface.CreateFont("KeypadAbort", {
        font = "Roboto",
        size = 45,
        weight = 900
    })

    surface.CreateFont("KeypadOK", {
        font = "Roboto",
        size = 60,
        weight = 900
    })

    surface.CreateFont("KeypadNumber", {
        font = "Roboto",
        size = 70,
        weight = 600
    })

    surface.CreateFont("KeypadEntry", {
        font = "Roboto",
        size = 120,
        weight = 900
    })

    surface.CreateFont("KeypadStatus", {
        font = "Roboto",
        size = 60,
        weight = 900
    })

    local COLOR_GREEN = Color(0, 255, 0)
    local COLOR_RED = Color(255, 0, 0)

    local function DrawLines(lines, x, y)
        local text = table.concat(lines, "\n")
        local total_w, total_h = surface.GetTextSize(text)
        local y_off = 0

        for k, v in ipairs(lines) do
            local w, h = surface.GetTextSize(v)
            surface.SetTextPos(x - w / 2, y - total_h / 2 + y_off)
            surface.DrawText(v)
            y_off = y_off + h
        end
    end

    local elements = {
        {
            x = 0.075,
            y = 0.04,
            w = 0.85,
            h = 0.25,
            color = Color(50, 75, 50, 255),
            render = function(self, x, y)
                local status = self:GetStatus()

                if status == self.Status_None then
                    surface.SetFont("KeypadEntry")
                    local text = self:GetText()
                    local textw, texth = surface.GetTextSize(text)
                    surface.SetTextColor(color_white)
                    surface.SetTextPos(x - textw / 2, y - texth / 2)
                    surface.DrawText(text)
                elseif status == self.Status_Denied then
                    surface.SetFont("KeypadStatus")
                    surface.SetTextColor(COLOR_RED)

                    if self:GetText() == "1337" then
                        DrawLines({"ACC355", "D3N13D"}, x, y)
                    else
                        DrawLines({"ACCESS", "DENIED"}, x, y)
                    end
                elseif status == self.Status_Granted then
                    surface.SetFont("KeypadStatus")
                    surface.SetTextColor(COLOR_GREEN)

                    if self:GetText() == "1337" then
                        DrawLines({"ACC355", "GRAN73D"}, x, y)
                    else
                        DrawLines({"ACCESS", "GRANTED"}, x, y)
                    end
                end
            end
        },
        -- Screen
        {
            x = 0.075,
            y = 0.04 + 0.25 + 0.03,
            w = 0.85 / 2 - 0.04 / 2 + 0.05,
            h = 0.125,
            color = Color(120, 25, 25),
            hovercolor = Color(180, 25, 25),
            text = "ABORT",
            font = "KeypadAbort",
            click = function(self)
                self:SendCommand(self.Command_Abort)
            end
        },
        -- ABORT
        {
            x = 0.5 + 0.04 / 2 + 0.05,
            y = 0.04 + 0.25 + 0.03,
            w = 0.85 / 2 - 0.04 / 2 - 0.05,
            h = 0.125,
            color = Color(25, 120, 25),
            hovercolor = Color(25, 180, 25),
            text = "OK",
            font = "KeypadOK",
            click = function(self)
                self:SendCommand(self.Command_Accept)
            end
        }
    }

    -- OK
    -- Create numbers
    do
        for i = 1, 9 do
            local column = (i - 1) % 3
            local row = math.floor((i - 1) / 3)

            local element = {
                x = 0.075 + (0.3 * column),
                y = 0.175 + 0.25 + 0.05 + ((0.5 / 3) * row),
                w = 0.25,
                h = 0.13,
                color = Color(120, 120, 120),
                hovercolor = Color(180, 180, 180),
                text = tostring(i),
                click = function(self)
                    self:SendCommand(self.Command_Enter, i)
                end
            }

            table.insert(elements, element)
        end
    end

    function ENT:Paint(w, h, x, y)
        local hovered = self:GetHoveredElement()

        for k, element in ipairs(elements) do
            surface.SetDrawColor(element.color)
            local element_x = w * element.x
            local element_y = h * element.y
            local element_w = w * element.w
            local element_h = h * element.h

            if element == hovered and element.hovercolor then
                surface.SetDrawColor(element.hovercolor)
            end

            surface.DrawRect(element_x, element_y, element_w, element_h)
            local cx = element_x + element_w / 2
            local cy = element_y + element_h / 2

            if element.text then
                surface.SetFont(element.font or "KeypadNumber")
                local textw, texth = surface.GetTextSize(element.text)
                surface.SetTextColor(color_black)
                surface.SetTextPos(cx - textw / 2, cy - texth / 2)
                surface.DrawText(element.text)
            end

            if element.render then
                element.render(self, cx, cy)
            end
        end
    end

    function ENT:GetHoveredElement()
        local scale = self.Scale
        local w, h = self.Width2D, self.Height2D
        local x, y = self:CalculateCursorPos()

        for _, element in ipairs(elements) do
            local element_x = w * element.x
            local element_y = h * element.y
            local element_w = w * element.w
            local element_h = h * element.h
            if element_x < x and element_x + element_w > x and element_y < y and element_y + element_h > y then return element end
        end
    end

    local mat = CreateMaterial("aeypad_baaaaaaaaaaaaaaaaaaase", "VertexLitGeneric", {
        ["$basetexture"] = "white",
        ["$color"] = "{ 36 36 36 }"
    })

    function ENT:Draw()
        render.SetMaterial(mat)
        render.DrawBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, color_white, true)
        local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()
        local w, h = self.Width2D, self.Height2D
        local x, y = self:CalculateCursorPos()
        local scale = self.Scale -- A high scale avoids surface call integerising from ruining aesthetics
        cam.Start3D2D(pos, ang, self.Scale)
        self:Paint(w, h, x, y)
        cam.End3D2D()
    end

    function ENT:SendCommand(command, data)
        net.Start("Wire_Keypad_Command")
        net.WriteEntity(self)
        net.WriteUInt(command, 4)

        if data then
            net.WriteUInt(data, 8)
        end

        net.SendToServer()
    end
end

ENT.Type = "anim"
ENT.Model = "models/props_lab/keypad.mdl"
ENT.Scale = 0.02
ENT.Value = ""
ENT.Status_None = 0
ENT.Status_Granted = 1
ENT.Status_Denied = 2
ENT.Command_Enter = 0
ENT.Command_Accept = 1
ENT.Command_Abort = 2
ENT.IsKeypad = true
AccessorFunc(ENT, "m_Password", "Password", FORCE_STRING)

function ENT:Initialize()
    self:SetModel(self.Model)

    if CLIENT then
        self.Mins = self:OBBMins()
        self.Maxs = self:OBBMaxs()
        self.Width2D, self.Height2D = (self.Maxs.y - self.Mins.y) / self.Scale, (self.Maxs.z - self.Mins.z) / self.Scale
    end

    if SERVER then
        if not WireLib then
            self:Remove()

            return
        end

        self.Outputs = Wire_CreateOutputs(self, {"Access Granted", "Access Denied"})
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
        end

        self:SetValue("")
        self:SetPassword("1337")
        -- Initialize defaults
        self:GetData()
        self:Reset()
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Text")
    self:NetworkVar("Int", 0, "Status")
    self:NetworkVar("Bool", 0, "Secure")
end

if SERVER then
    util.AddNetworkString("Wire_Keypad_Command")

    net.Receive("Wire_Keypad_Command", function(_, ply)
        local ent = net.ReadEntity()
        if not IsValid(ply) or not IsValid(ent) or ent:GetClass() ~= "gmod_wire_keypad" then return end
        if ent:GetStatus() ~= ent.Status_None then return end
        if ply:GetShootPos():DistToSqr(ent:GetPos()) >= (120 * 120) then return end
        if ent.Next_Command_Time and ent.Next_Command_Time > CurTime() then return end
        ent.Next_Command_Time = CurTime() + 0.05
        local command = net.ReadUInt(4)

        if command == ent.Command_Enter then
            local val = tonumber(ent:GetValue() .. net.ReadUInt(8))

            if val and val > 0 and val <= 9999 then
                ent:SetValue(tostring(val))
                ent:EmitSound("buttons/button15.wav")
            end
        elseif command == ent.Command_Abort then
            ent:SetValue("")
        elseif command == ent.Command_Accept then
            if ent:GetValue() == ent:GetPassword() then
                ent:Process(true)
            else
                ent:Process(false)
            end
        end
    end)

    function ENT:SetValue(val)
        self.Value = val

        if self:GetSecure() then
            self:SetText(string.rep("*", #val))
        else
            self:SetText(val)
        end
    end

    function ENT:GetValue()
        return self.Value
    end

    function ENT:Process(granted)
        self:GetData()
        local length, repeats, delay, initdelay, outputKey

        if (granted) then
            self:SetStatus(self.Status_Granted)
            length = self.KeypadData.LengthGranted
            repeats = math.min(self.KeypadData.RepeatsGranted, 50)
            delay = self.KeypadData.DelayGranted
            initdelay = self.KeypadData.InitDelayGranted
            outputKey = "Access Granted"
        else
            self:SetStatus(self.Status_Denied)
            length = self.KeypadData.LengthDenied
            repeats = math.min(self.KeypadData.RepeatsDenied, 50)
            delay = self.KeypadData.DelayDenied
            initdelay = self.KeypadData.InitDelayDenied
            outputKey = "Access Denied"
        end

        -- 0.25 after last timer
        timer.Simple(math.max(initdelay + length * (repeats + 1) + delay * repeats + 0.25, 2), function()
            if (IsValid(self)) then
                self:Reset()
            end
        end)

        timer.Simple(initdelay, function()
            if (IsValid(self)) then
                for i = 0, repeats do
                    timer.Simple(length * i + delay * i, function()
                        if (IsValid(self)) then
                            Wire_TriggerOutput(self, outputKey, self.KeypadData.OutputOn)
                        end
                    end)

                    timer.Simple(length * (i + 1) + delay * i, function()
                        if (IsValid(self)) then
                            Wire_TriggerOutput(self, outputKey, self.KeypadData.OutputOff)
                        end
                    end)
                end
            end
        end)

        if (granted) then
            self:EmitSound("buttons/button9.wav")
        else
            self:EmitSound("buttons/button11.wav")
        end
    end

    function ENT:SetData(data)
        self.KeypadData = data
        self:SetPassword(data.Password or "1337")
        self:Reset()
        duplicator.StoreEntityModifier(self, "keypad_wire_password_passthrough", self.KeypadData)
    end

    function ENT:GetData()
        if not self.KeypadData then
            self:Setup(1337, false)
        end

        return self.KeypadData
    end

    function ENT:Setup(password, securemode)
        self:SetData({
            Password = password,
            RepeatsGranted = 0,
            RepeatsDenied = 0,
            LengthGranted = 5,
            LengthDenied = 0,
            DelayGranted = 0,
            DelayDenied = 0,
            InitDelayGranted = 0,
            InitDelayDenied = 0,
            OutputOn = 1,
            OutputOff = 0,
            Secure = securemode
        })
    end

    function ENT:Reset()
        self:GetData()
        self:SetValue("")
        self:SetStatus(self.Status_None)
        self:SetSecure(self.KeypadData.Secure)
        Wire_TriggerOutput(self, "Access Granted", self.KeypadData.OutputOff)
        Wire_TriggerOutput(self, "Access Denied", self.KeypadData.OutputOff)
    end

    duplicator.RegisterEntityModifier("keypad_wire_password_passthrough", function(ply, entity, data)
        entity:SetData(data)
    end)
end