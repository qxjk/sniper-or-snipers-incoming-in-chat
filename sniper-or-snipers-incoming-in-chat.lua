sniper = sniper or { alive = 0, last_announce = -100, delay = 0.25, next_scan = 0 }
local s = sniper

local function msg(text)
    if managers.chat then
        managers.chat:_receive_message(1, "WARNING", text, Color.red)
    elseif managers.hud then
        managers.hud:show_hint({ text = text })
    end
end

local function now()
    local g = TimerManager and TimerManager:game()
    return g and g:time()
end

function s:reset()
    self.alive, self.last_announce, self.next_scan = 0, -100, 0
end

function s:announce()
    local t = now()
    if not t or t < self.last_announce + self.delay then return end
    self.last_announce = t
    msg(self.alive <= 1 and "SNIPER INCOMING!" or "SNIPERS INCOMING!")
end

local function is_sniper(u)
    local b = alive(u) and u:base()
    return b and b.has_tag and b:has_tag("sniper")
end

function s:scan()
    local t = now()
    if not t or t < self.next_scan then return end
    self.next_scan = t + self.delay

    local e = managers.enemy and managers.enemy:all_enemies()
    if not e then return end

    local c = 0
    for _, d in pairs(e) do
        if is_sniper(d.unit) then
            c = c + 1
        end
    end

    local old = self.alive
    self.alive = c
    if c > old then
        self:announce()
    end
end

if RequiredScript == "lib/setups/gamesetup" then
    Hooks:PostHook(GameSetup, "init_game", "GameSetupInitGameReset", function()
        s:reset()
    end)

    Hooks:PostHook(GameSetup, "update", "GameSetupUpdateScan", function()
        s:scan()
    end)
end
