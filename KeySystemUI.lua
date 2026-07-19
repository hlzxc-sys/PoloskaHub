--!nocheck

local KeysystemUI = {}
KeysystemUI.__index = KeysystemUI

function KeysystemUI.new(options)
    assert(
        type(options) == "table",
        "KeysystemUI options are required"
    )

    local PoloskaLib = options.PoloskaLib

    assert(
        type(PoloskaLib) == "table",
        "PoloskaLib is required"
    )

    local self = setmetatable({}, KeysystemUI)

    self.Busy = false
    self.RememberKey = options.RememberKey ~= false
    self.EnteredKey = tostring(options.DefaultKey or "")

    self.Window = PoloskaLib:Create({
        Name = options.Title or "Poloska Access",
        Size = options.Size or UDim2.fromOffset(440, 410),
    })

    self.Tab = self.Window:Tab({
        Name = "Key System",
    })

    self.Tab:Section(
        options.Description
            or "Один ключ предоставляет доступ ко всем играм PoloskaHub."
    )

    self.StatusLabel = self.Tab:Section(
        "Статус: ожидание ключа"
    )

    self.KeyElement = self.Tab:Textbox({
        Name = "License key",
        Placeholder = "Введите ключ PandaAuth...",
        Default = self.EnteredKey,
        Stacked = true,

        Callback = function(value)
            self.EnteredKey = self:_trim(value)
        end,
    })

    self.KeyTextBox =
        self.KeyElement:FindFirstChildWhichIsA(
            "TextBox",
            true
        )

    self.RememberToggle = self.Tab:Toggle({
        Name = "Сохранить ключ на устройстве",
        StartingState = self.RememberKey,

        Callback = function(value)
            self.RememberKey = value == true
        end,
    })

    self.Tab:Button({
        Name = "Проверить ключ",

        Callback = function()
            if self.Busy then
                return
            end

            if type(options.OnValidate) == "function" then
                options.OnValidate(
                    self:GetKey(),
                    self
                )
            end
        end,
    })

    self.Tab:Button({
        Name = "Получить ключ",

        Callback = function()
            if self.Busy then
                return
            end

            if type(options.OnGetKey) == "function" then
                options.OnGetKey(self)
            end
        end,
    })

    self.Tab:Button({
        Name = "Удалить сохранённый ключ",

        Callback = function()
            if self.Busy then
                return
            end

            self:SetKey("")

            if type(options.OnForgetKey) == "function" then
                options.OnForgetKey(self)
            end
        end,
    })

    return self
end

function KeysystemUI:_trim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

function KeysystemUI:GetKey()
    if self.KeyTextBox then
        self.EnteredKey = self:_trim(
            self.KeyTextBox.Text
        )
    end

    return self.EnteredKey
end

function KeysystemUI:SetKey(value)
    self.EnteredKey = self:_trim(value)

    if self.KeyTextBox then
        self.KeyTextBox.Text = self.EnteredKey
    end
end

function KeysystemUI:GetRememberKey()
    return self.RememberKey
end

function KeysystemUI:SetBusy(value, message)
    self.Busy = value == true

    if message then
        self:SetStatus(message)
    elseif self.Busy then
        self:SetStatus("Проверка ключа...")
    else
        self:SetStatus("Ожидание ключа")
    end
end

function KeysystemUI:SetStatus(text)
    if self.StatusLabel and self.StatusLabel.Parent then
        self.StatusLabel.Text =
            "Статус: " .. tostring(text)
    end
end

function KeysystemUI:Notify(title, text, duration)
    if not self.Window
        or not self.Window.Gui
        or not self.Window.Gui.Parent then
        return
    end

    self.Window:Notification({
        Title = title or "PoloskaHub",
        Text = text or "",
        Duration = duration or 4,
    })
end

function KeysystemUI:Destroy()
    if self.Window
        and self.Window.Gui
        and self.Window.Gui.Parent then
        self.Window.Gui:Destroy()
    end
end

return KeysystemUI