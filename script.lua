local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- MAIN HUB (RAYFIELD UI)
---------------------------------------------------------------------

        -----------------------------------------------------------------
        -- SERVICES / ENV
        -----------------------------------------------------------------
        local Services = {
            Players          = game:GetService("Players"),
            RunService       = game:GetService("RunService"),
            UserInputService = game:GetService("UserInputService"),
            SoundService     = game:GetService("SoundService"),
            StarterGui       = game:GetService("StarterGui"),
            TextChatService  = game:GetService("TextChatService"),
            Lighting         = game:GetService("Lighting"),
            TeleportService  = game:GetService("TeleportService"),
            CoreGui          = game:GetService("CoreGui"),
            ReplicatedStorage= game:GetService("ReplicatedStorage")
        }

        local LocalPlayer = Services.Players.LocalPlayer

        local safeGetGenv = getgenv or function()
            _G.__GENV = _G.__GENV or {}
            return _G.__GENV
        end
        local safeSetHidden = sethiddenproperty or function() end
        local GENV = safeGetGenv()

        local function playSound(soundId)
            pcall(function()
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://" .. soundId
                s.Parent = Services.SoundService
                s.Volume = 0.6
                s:Play()
                s.Ended:Connect(function()
                    s:Destroy()
                end)
            end)
        end

        playSound("2865227271")

        -----------------------------------------------------------------
        -- RAYFIELD LOAD
        -----------------------------------------------------------------
        local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

        local Window = Rayfield:CreateWindow({
            Name = "WINTER HUB | v4.3",
            LoadingTitle = "Winter Hub de Desastres Naturais",
            LoadingSubtitle = "Por Winter",
            ConfigurationSaving = {
                Enabled = false
            },
        })

        -----------------------------------------------------------------
        -- SHARED HELPERS
        -----------------------------------------------------------------
        local function getRoot()
            local c = LocalPlayer.Character
            return c and c:FindFirstChild("HumanoidRootPart") or nil
        end

        local function getNearbyParts(position, radius)
            local ok, parts = pcall(function()
                return workspace:GetPartBoundsInRadius(position, radius, nil)
            end)
            if ok and parts then
                return parts
            end
            return {}
        end

        -----------------------------------------------------------------
        -- NETWORK / BASE RING INFRA
        -----------------------------------------------------------------
        if not GENV.Network then
            GENV.Network = {
                BaseParts = {},
                Velocity  = Vector3.new(14.46, 14.46, 14.46)
            }
            local Network = GENV.Network

            function Network.RetainPart(p)
                if typeof(p) == "Instance" and p:IsA("BasePart") and p:IsDescendantOf(workspace) then
                    table.insert(Network.BaseParts, p)
                    local oldProps = p.CustomPhysicalProperties
                    local density = 0.1
                    local friction = 0
                    local elasticity = 0
                    local frictionWeight = 0
                    local elasticityWeight = 0

                    if oldProps then
                        density = math.clamp(oldProps.Density, 0.0001, 100)
                        friction = oldProps.Friction
                        elasticity = oldProps.Elasticity
                        frictionWeight = oldProps.FrictionWeight
                        elasticityWeight = oldProps.ElasticityWeight
                    end

                    p.CustomPhysicalProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
                    p.CanCollide = false
                    return true
                end
                return false
            end

            Services.RunService.Heartbeat:Connect(function()
                pcall(function() safeSetHidden(LocalPlayer, "SimulationRadius", math.huge) end)
                for _, bp in pairs(Network.BaseParts) do
                    if bp:IsDescendantOf(workspace) then
                        bp.Velocity = Network.Velocity
                    end
                end
            end)
        end

        local Network = GENV.Network

        -----------------------------------------------------------------
        -- SHARED PHYSICS PREP (USED BY AURA / BLACKHOLE / MAP DESTROY)
        -----------------------------------------------------------------
        local function preparePhysicsPart(p)
            if not (p and p:IsA("BasePart")) then return end
            if not p:IsDescendantOf(workspace) then return end
            if p:IsDescendantOf(LocalPlayer.Character or Instance.new("Model")) then return end

            if p.Anchored then
                p.Anchored = false
            end

            local oldProps = p.CustomPhysicalProperties
            local density = 0.1
            local friction = 0
            local elasticity = 0
            local frictionWeight = 0
            local elasticityWeight = 0

            if oldProps then
                density = math.clamp(oldProps.Density, 0.0001, 100)
                friction = oldProps.Friction
                elasticity = oldProps.Elasticity
                frictionWeight = oldProps.FrictionWeight
                elasticityWeight = oldProps.ElasticityWeight
            end

            p.CustomPhysicalProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
            p.CanCollide = false

            -- Push through global network system so velocity sticks & replicates better
            if not table.find(Network.BaseParts, p) then
                table.insert(Network.BaseParts, p)
            end
        end

        -----------------------------------------------------------------
        -- RING SETTINGS
        -----------------------------------------------------------------
        local Ring = {
            Radius         = 50,
            MinDist        = 6,
            Height         = 40,
            RotSpeed       = 6,
            Force          = 800,
            HeightOffset   = 6,
            Enabled        = false,
            Parts          = {},
            Speed          = 6,

            Pattern        = "Orbit", -- Orbit / Vertical / Wave / Sphere / SpherePulsing / Chaos / Spiral / Helix / Pulse / RandomShell

            SphereRadius   = 30,
            SphereSpeed    = 1.2,
            ChaosAmount    = 6,

            SpiralHeight   = 18,
            HelixTwist     = 2.3,
            PulseAmount    = 10,
            RandomShellJitter = 5
        }

        local function retainRingPart(part)
            if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(workspace) then
                if part.Parent == LocalPlayer.Character or part:IsDescendantOf(LocalPlayer.Character) then
                    return false
                end

                local oldProps = part.CustomPhysicalProperties
                local density = 0.1
                local friction = 0
                local elasticity = 0
                local frictionWeight = 0
                local elasticityWeight = 0

                if oldProps then
                    density = math.clamp(oldProps.Density, 0.0001, 100)
                    friction = oldProps.Friction
                    elasticity = oldProps.Elasticity
                    frictionWeight = oldProps.FrictionWeight
                    elasticityWeight = oldProps.ElasticityWeight
                end

                part.CustomPhysicalProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
                part.CanCollide = false

                if not table.find(Ring.Parts, part) then
                    table.insert(Ring.Parts, part)
                end

                -- also feed into Network system
                if not table.find(Network.BaseParts, part) then
                    table.insert(Network.BaseParts, part)
                end

                return true
            end
            return false
        end

        local function addRingPart(p)
            if retainRingPart(p) and not table.find(Ring.Parts, p) then
                table.insert(Ring.Parts, p)
            end
        end

        local function removeRingPart(p)
            local i = table.find(Ring.Parts, p)
            if i then table.remove(Ring.Parts, i) end
        end

        workspace.DescendantAdded:Connect(addRingPart)
        workspace.DescendantRemoving:Connect(removeRingPart)

        local function clampRingVelocity(part, rootPos)
            local rel = part.Position - rootPos
            if rel.Magnitude < Ring.MinDist + 2 then
                local v = part.Velocity
                part.Velocity = Vector3.new(v.X, math.clamp(v.Y, -35, 35), v.Z)
            end
        end

        -----------------------------------------------------------------
        -- MOVEMENT / FLIGHT
        -----------------------------------------------------------------
        local Movement = {
            Flying       = false,
            FlightSpeed  = 60,
            BaseWalk     = 20,
            BaseJump     = 60,
            BaseMaxHP    = 200,
            BodyGyro     = nil,
            BodyVel      = nil
        }

        local function getHumanoid()
            local c = LocalPlayer.Character
            return c and c:FindFirstChildOfClass("Humanoid") or nil
        end

        local function applyMovementStats()
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = Movement.BaseWalk
                hum.JumpPower = Movement.BaseJump
            end
        end

        applyMovementStats()

        local function startFlight()
            if Movement.Flying then return end
            local root, hum = getRoot(), getHumanoid()
            if not root or not hum then return end

            Movement.Flying = true
            hum.PlatformStand = true

            local bg = Instance.new("BodyGyro")
            bg.P = 9e4
            bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            bg.CFrame = root.CFrame
            bg.Parent = root
            Movement.BodyGyro = bg

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            Movement.BodyVel = bv

            playSound("12221967")
        end

        local function stopFlight()
            if not Movement.Flying then return end
            local hum = getHumanoid()
            Movement.Flying = false

            if Movement.BodyGyro then Movement.BodyGyro:Destroy() Movement.BodyGyro = nil end
            if Movement.BodyVel  then Movement.BodyVel:Destroy()  Movement.BodyVel  = nil end
            if hum then hum.PlatformStand = false end

            playSound("12221967")
        end

        Services.RunService.Heartbeat:Connect(function()
            if not Movement.Flying then return end
            local root = getRoot()
            local cam  = workspace.CurrentCamera
            if not root or not cam or not Movement.BodyGyro or not Movement.BodyVel then return end

            Movement.BodyGyro.CFrame = cam.CFrame

            local dir = Vector3.new()
            local UIS = Services.UserInputService

            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

            if dir.Magnitude > 0 then
                dir = dir.Unit
                Movement.BodyVel.Velocity = dir * Movement.FlightSpeed
            else
                Movement.BodyVel.Velocity = Vector3.new(0, 0, 0)
            end
        end)

        -----------------------------------------------------------------
        -- GODMODE
        -----------------------------------------------------------------
        local God = {
            Enabled      = false,
            HealThresh   = 60,
            MinHeal      = 20,
            MaxHeal      = 95,
            MinMaxHP     = 100,
            MaxMaxHP     = 1000,
            AntiFall     = true,
            HeartbeatCon = nil,
            HealthCon    = nil
        }

        local function addForceField(character)
            if not character or character:FindFirstChildOfClass("ForceField") then return end
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = character
        end

        local function applyHPStats(h)
            if not h then return end
            h.WalkSpeed = Movement.BaseWalk
            h.JumpPower = Movement.BaseJump
            h.MaxHealth = Movement.BaseMaxHP
            local th = h.MaxHealth * (God.HealThresh / 100)
            if h.Health < th then
                h.Health = h.MaxHealth
            end
        end

        local function enableGodOnChar(char)
            local h = char and char:FindFirstChildOfClass("Humanoid")
            if not h then return end

            if God.HeartbeatCon then God.HeartbeatCon:Disconnect() God.HeartbeatCon = nil end
            if God.HealthCon   then God.HealthCon:Disconnect()   God.HealthCon   = nil end

            applyHPStats(h)
            addForceField(char)

            God.HealthCon = h.HealthChanged:Connect(function(health)
                if not God.Enabled then return end
                if health <= 0 then
                    task.spawn(function()
                        pcall(function() LocalPlayer:LoadCharacter() end)
                    end)
                else
                    applyHPStats(h)
                end
            end)

            God.HeartbeatCon = Services.RunService.Heartbeat:Connect(function()
                if not God.Enabled then return end
                if h.Health > 0 then
                    applyHPStats(h)
                    addForceField(char)
                    if God.AntiFall then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local v = root.Velocity
                            if v.Y < -90 then
                                local nv = Vector3.new(v.X, -50, v.Z)
                                root.Velocity = nv
                                root.AssemblyLinearVelocity = nv
                            end
                        end
                    end
                end
            end)
        end

        local function disableGod()
            if God.HeartbeatCon then God.HeartbeatCon:Disconnect() God.HeartbeatCon = nil end
            if God.HealthCon   then God.HealthCon:Disconnect()   God.HealthCon   = nil end
        end

        LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid", 10)
            applyMovementStats()
            if God.Enabled then
                enableGodOnChar(char)
            end
        end)

        if LocalPlayer.Character then
            applyMovementStats()
            if God.Enabled then enableGodOnChar(LocalPlayer.Character) end
        end

        -----------------------------------------------------------------
        -- NOCLIP & ANTI-AFK / AUTO REJOIN
        -----------------------------------------------------------------
        local Noclip = { Enabled = false }

        local function setCharCollide(char, collide)
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = collide
                end
            end
        end

        Services.RunService.Stepped:Connect(function()
            if Noclip.Enabled then
                local c = LocalPlayer.Character
                if c then setCharCollide(c, false) end
            end
        end)

        local AntiAFK = { Enabled = false, Conn = nil }
        local AutoRejoin = { Enabled = false }

        pcall(function()
            local promptGui = Services.CoreGui:WaitForChild("RobloxPromptGui", 10)
            if promptGui and promptGui:FindFirstChild("promptOverlay") then
                promptGui.promptOverlay.ChildAdded:Connect(function(obj)
                    if not AutoRejoin.Enabled then return end
                    task.wait(0.1)
                    if obj.Name == "ErrorPrompt" or obj:FindFirstChild("ErrorMessage", true) then
                        pcall(function()
                            Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end)
                    end
                end)
            end
        end)

        -----------------------------------------------------------------
        -- DESTRUCTIVE AURA (IMPROVED)
        -----------------------------------------------------------------
        local Aura = {
            Enabled      = false,
            BreakEnabled = false,
            Radius       = 80,
            Force        = 2600,
            YClamp       = 60,
            Cooldown     = 0.08,
            LastTime     = 0,
            TargetFilter = {"Baseplate", "SpawnLocation", "lobby"}
        }

        local function isIgnoredAuraPart(part)
            if not part or not part:IsA("BasePart") then return true end
            local name = part.Name:lower()
            for _, ignoreName in ipairs(Aura.TargetFilter) do
                if name:find(ignoreName:lower()) then
                    return true
                end
            end
            return false
        end

        Services.RunService.Heartbeat:Connect(function()
            if not Aura.Enabled then return end
            local root = getRoot()
            if not root then return end

            local now = tick()
            if now - Aura.LastTime < Aura.Cooldown then return end
            Aura.LastTime = now

            local rootPos = root.Position
            local nearby = getNearbyParts(rootPos, Aura.Radius)

            for _, p in ipairs(nearby) do
                if p:IsA("BasePart") and p ~= root and not p:IsDescendantOf(LocalPlayer.Character) then
                    if not isIgnoredAuraPart(p) then
                        preparePhysicsPart(p)

                        if Aura.BreakEnabled then
                            p.CanCollide = false
                        end

                        local offset = p.Position - rootPos
                        local dist = offset.Magnitude
                        if dist < 1 then
                            offset = Vector3.new(1, 0, 0)
                            dist = 1
                        end

                        local dir = offset.Unit
                        local push = dir * Aura.Force
                        push = Vector3.new(
                            math.clamp(push.X, -2000, 2000),
                            math.clamp(push.Y + 240, -Aura.YClamp, Aura.YClamp),
                            math.clamp(push.Z, -2000, 2000)
                        )

                        local newVel = p.Velocity + push
                        newVel = Vector3.new(
                            math.clamp(newVel.X, -550, 550),
                            math.clamp(newVel.Y, -Aura.YClamp, Aura.YClamp),
                            math.clamp(newVel.Z, -550, 550)
                        )

                        p.Velocity = newVel
                        p.AssemblyLinearVelocity = newVel
                    end
                end
            end
        end)

        -----------------------------------------------------------------
        -- RING PHYSICS (uses Ring table)
        -----------------------------------------------------------------
        Services.RunService.Heartbeat:Connect(function()
            if not Ring.Enabled then return end
            local root = getRoot()
            if not root then return end

            local rootPos = root.Position
            local center = rootPos + Vector3.new(0, Ring.HeightOffset, 0)

            for _, p in pairs(Ring.Parts) do
                if p.Parent and not p.Anchored then
                    local offset = p.Position - center
                    local flat   = Vector3.new(offset.X, 0, offset.Z)
                    local dist   = flat.Magnitude
                    if dist < 1 then
                        flat = Vector3.new(1, 0, 0)
                        dist = 1
                    end

                    local angle = math.atan2(flat.Z, flat.X)
                    local newAngle = angle + math.rad(Ring.Speed)
                    local r = math.max(Ring.Radius, Ring.MinDist)

                    local targetPos

                    if Ring.Pattern == "Sphere" or Ring.Pattern == "SpherePulsing" then
                        local t = tick() * Ring.SphereSpeed
                        local yaw   = angle + t * 0.6
                        local pitch = math.sin((offset.X + offset.Z) * 0.03 + t) * math.pi * 0.4

                        local baseR = Ring.SphereRadius
                        if Ring.Pattern == "SpherePulsing" then
                            baseR = baseR + math.sin(t * 1.4) * 6
                        end

                        local dir = Vector3.new(
                            math.cos(pitch) * math.cos(yaw),
                            math.sin(pitch),
                            math.cos(pitch) * math.sin(yaw)
                        )

                        targetPos = center + dir.Unit * baseR

                    elseif Ring.Pattern == "Chaos" then
                        local t = tick() * Ring.SphereSpeed
                        local baseY = center.Y
                        local yOffset = math.sin((offset.X + offset.Z) * 0.12 + t * 2.2) * (Ring.Height * 0.35)

                        local noiseX = (math.noise(offset.X * 0.05, t) or 0) * Ring.ChaosAmount
                        local noiseZ = (math.noise(offset.Z * 0.05, t + 100) or 0) * Ring.ChaosAmount
                        local noiseY = (math.noise(offset.X * 0.05, offset.Z * 0.05, t + 200) or 0) * (Ring.ChaosAmount * 0.7)

                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * r + noiseX,
                            baseY + yOffset + noiseY,
                            center.Z + math.sin(newAngle) * r + noiseZ
                        )

                    elseif Ring.Pattern == "Spiral" then
                        local t = tick() * 0.9
                        local spiralY = math.sin(angle * 2 + t) * Ring.SpiralHeight
                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * r,
                            center.Y + spiralY,
                            center.Z + math.sin(newAngle) * r
                        )

                    elseif Ring.Pattern == "Helix" then
                        local t = tick()
                        local helixPhase = angle * Ring.HelixTwist + t * 2
                        local helixY = math.sin(helixPhase) * Ring.SpiralHeight

                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * r,
                            center.Y + helixY,
                            center.Z + math.sin(newAngle) * r
                        )

                    elseif Ring.Pattern == "Pulse" then
                        local t = tick() * 2
                        local pulseR = r + math.sin(t + angle * 1.3) * Ring.PulseAmount

                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * pulseR,
                            center.Y + math.sin(t + angle) * (Ring.Height * 0.3),
                            center.Z + math.sin(newAngle) * pulseR
                        )

                    elseif Ring.Pattern == "RandomShell" then
                        local t = tick() * 1.3
                        local nr = r + (math.noise(offset.X * 0.1, offset.Z * 0.1, t) or 0) * Ring.RandomShellJitter
                        local ny = (math.noise(offset.X * 0.07, t) or 0) * Ring.SpiralHeight

                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * nr,
                            center.Y + ny,
                            center.Z + math.sin(newAngle) * nr
                        )

                    else
                        local baseY = center.Y
                        local yOffset = 0

                        if Ring.Pattern == "Orbit" then
                            yOffset = math.sin(time() * 1.2) * (Ring.Height * 0.25)
                        elseif Ring.Pattern == "Vertical" then
                            yOffset = math.sin(angle * 2 + time() * 2) * (Ring.Height * 0.5)
                        elseif Ring.Pattern == "Wave" then
                            yOffset = math.sin((offset.X + offset.Z) * 0.1 + time() * 3) * (Ring.Height * 0.3)
                        end

                        targetPos = Vector3.new(
                            center.X + math.cos(newAngle) * r,
                            baseY + yOffset,
                            center.Z + math.sin(newAngle) * r
                        )
                    end

                    local dir = targetPos - p.Position
                    local d   = dir.Magnitude
                    if d > 0 then
                        local vel = dir.Unit * Ring.Force
                        if d < 10 then
                            vel = vel * 0.4
                        elseif d > 60 then
                            vel = vel * 1.5
                        end
                        if vel.Magnitude > 220 then
                            vel = vel.Unit * 220
                        end
                        p.Velocity = vel
                        clampRingVelocity(p, rootPos)
                    end
                end
            end
        end)

        -----------------------------------------------------------------
        -- TELEPORT SYSTEM (same logic, UI later)
        -----------------------------------------------------------------
        local TP = {
            Mode        = "ToPlayer",  -- or "ToLobby", "Smooth"
            Target      = nil,
            LobbyCFrame = nil,
            InProgress  = false,

            SafeRadius  = 3,
            SideOffset  = 1.5,
            AutoFollow  = false,
            Orbit       = false,
            StayAbove   = false,

            SnapHeight  = false,
            OffsetUp    = 0
        }

        local function getValidRandomPlayer()
            local list = {}
            for _, plr in ipairs(Services.Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(list, plr)
                end
            end
            if #list == 0 then return nil end
            return list[math.random(1, #list)]
        end

        local function safeTeleportCFrame(cf)
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then return end

            cf = cf + Vector3.new(0, 2.5, 0)

            setCharCollide(c, false)

            r.Velocity = Vector3.new()
            r.AssemblyLinearVelocity = Vector3.new()
            r.AssemblyAngularVelocity = Vector3.new()
            r.CFrame = cf

            task.delay(0.4, function()
                if c then setCharCollide(c, true) end
            end)
        end

        local function smoothTeleportTo(targetCF)
            if TP.InProgress then return end
            TP.InProgress = true

            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then TP.InProgress = false return end

            local startCF = r.CFrame
            local steps, delayStep = 16, 0.02

            setCharCollide(c, false)

            for i = 1, steps do
                if not c or not r then break end

                local t = i / steps
                local alpha = t * t * (3 - 2 * t)

                local newCF = startCF:Lerp(targetCF, alpha)
                newCF = newCF + Vector3.new(0, 2.5, 0)

                r.CFrame = newCF

                r.Velocity = Vector3.new()
                r.AssemblyLinearVelocity = Vector3.new()
                r.AssemblyAngularVelocity = Vector3.new()

                task.wait(delayStep)
            end

            task.delay(0.3, function()
                if c then setCharCollide(c, true) end
            end)

            TP.InProgress = false
        end

        local function getSafeTargetCF(tr, fromPos)
            local baseDist = (fromPos - tr.Position).Magnitude

            local backOffset = TP.SafeRadius
            if baseDist < 8 then
                backOffset = math.max(2, TP.SafeRadius - 1)
            elseif baseDist > 80 then
                backOffset = TP.SafeRadius + 2
            end

            local cf = tr.CFrame * CFrame.new(0, 0, -backOffset)
            local sideSign = (math.random(0, 1) == 0) and -1 or 1
            local sideOffset = TP.SideOffset * sideSign
            cf = cf * CFrame.new(sideOffset, 0, 0)

            if TP.StayAbove then
                cf = cf * CFrame.new(0, 2, 0)
            end

            if TP.SnapHeight then
                local y = tr.Position.Y + TP.OffsetUp
                cf = CFrame.new(cf.Position.X, y, cf.Position.Z, cf:ToOrientation())
            else
                cf = cf * CFrame.new(0, TP.OffsetUp, 0)
            end

            return cf
        end

        local function teleportToTarget()
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r or not TP.Target then return end

            if TP.Mode == "ToLobby" then
                if TP.LobbyCFrame then
                    local lobbyCF = TP.LobbyCFrame * CFrame.new(0, 3 + TP.OffsetUp, 0)
                    safeTeleportCFrame(lobbyCF)
                    playSound("12221967")
                end
                return
            end

            local tChar = TP.Target.Character
            local tr = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not tr then return end

            local targetCF = getSafeTargetCF(tr, r.Position)

            if TP.Mode == "Smooth" then
                smoothTeleportTo(targetCF)
            else
                safeTeleportCFrame(targetCF)
            end

            playSound("12221967")
        end

        local function randomTeleport()
            local plr = getValidRandomPlayer()
            if not plr then return end

            TP.Target = plr

            local tChar = plr.Character
            local tr = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not tr then return end

            if TP.Mode == "ToLobby" then
                local lobbyCF = tr.CFrame * CFrame.new(0, 3 + TP.OffsetUp, 0)
                safeTeleportCFrame(lobbyCF)
                playSound("12221967")
                return
            end

            local fromRoot = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            local fromPos = fromRoot and fromRoot.Position or tr.Position

            local cf = getSafeTargetCF(tr, fromPos)

            if TP.Mode == "Smooth" then
                smoothTeleportTo(cf)
            else
                safeTeleportCFrame(cf)
            end

            playSound("12221967")
        end

        Services.RunService.Heartbeat:Connect(function(dt)
            if not TP.AutoFollow or not TP.Target then return end
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local tChar = TP.Target.Character
            local tr = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not r or not tr then return end

            local fromPos = r.Position
            local baseCF = tr.CFrame

            if TP.Orbit then
                local angle = tick() * 0.8
                local orbitRadius = math.max(TP.SafeRadius, 4)
                local ofs = Vector3.new(math.cos(angle) * orbitRadius, 0, math.sin(angle) * orbitRadius)
                baseCF = CFrame.new(tr.Position + ofs, tr.Position)
            end

            local desiredCF = getSafeTargetCF(baseCF, fromPos)

            if TP.Mode == "Smooth" then
                local alpha = math.clamp(dt * 4, 0, 1)
                local blended = r.CFrame:Lerp(desiredCF, alpha)
                r.CFrame = blended
            else
                r.CFrame = desiredCF
            end
        end)

        -----------------------------------------------------------------
        -- MISC: ESP, INVIS, FPS, FREEZE
        -----------------------------------------------------------------
        local MiscState = {
            ESP        = false,
            Invis      = false,
            FPSBoost   = false,
            Freeze     = false,
            FrozenCF   = nil,
            ESPFolder  = nil,
            OrigTrans  = {},
            OrigName   = {},

            ESPBox       = false,
            ESPHealth    = false,
            ESPNameDist  = false,
            ESPTracers   = false
        }

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "WinterRingHubGUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = (LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10))

        local espFolder = Instance.new("Folder")
        espFolder.Name = "WinterRingESP"
        espFolder.Parent = ScreenGui
        MiscState.ESPFolder = espFolder

        local function clearESP()
            espFolder:ClearAllChildren()
        end

        local function getTeamColorForPlayer(plr)
            local tc = Color3.fromRGB(110, 170, 230)
            local team = plr.Team
            if team and team.TeamColor then
                tc = team.TeamColor.Color
            end
            return tc
        end

        local function createESPForPlayer(plr)
            if plr == LocalPlayer or not MiscState.ESP then return end
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or espFolder:FindFirstChild(plr.Name .. "_Billboard") then return end

            local distance = 0
            local myRoot = getRoot()
            if myRoot then
                distance = math.floor((hrp.Position - myRoot.Position).Magnitude)
            end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = plr.Name .. "_Billboard"
            billboard.Adornee = hrp
            billboard.Size = UDim2.new(0, 160, 0, 60)
            billboard.AlwaysOnTop = true
            billboard.Parent = espFolder

            local bgFrame = Instance.new("Frame")
            bgFrame.Size = UDim2.new(1, 0, 1, 0)
            bgFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
            bgFrame.BackgroundTransparency = 0.35
            bgFrame.BorderSizePixel = 0
            bgFrame.Parent = billboard

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = bgFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = getTeamColorForPlayer(plr)
            stroke.Parent = bgFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, -4, 0, 20)
            nameLabel.Position = UDim2.new(0, 2, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Text = plr.Name
            nameLabel.Parent = bgFrame

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Name = "InfoLabel"
            infoLabel.Size = UDim2.new(1, -4, 0, 18)
            infoLabel.Position = UDim2.new(0, 2, 0, 20)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 12
            infoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Text = "Dist: " .. distance .. " studs"
            infoLabel.Parent = bgFrame

            local healthLabel = Instance.new("TextLabel")
            healthLabel.Name = "HealthLabel"
            healthLabel.Size = UDim2.new(1, -4, 0, 16)
            healthLabel.Position = UDim2.new(0, 2, 0, 38)
            healthLabel.BackgroundTransparency = 1
            healthLabel.Font = Enum.Font.Gotham
            healthLabel.TextSize = 12
            healthLabel.TextXAlignment = Enum.TextXAlignment.Left
            healthLabel.Text = "HP: -"
            healthLabel.Parent = bgFrame

            local boxAdornment = Instance.new("BoxHandleAdornment")
            boxAdornment.Name = plr.Name .. "_Box"
            boxAdornment.Size = Vector3.new(4, 7, 4)
            boxAdornment.Color3 = getTeamColorForPlayer(plr)
            boxAdornment.Transparency = 0.5
            boxAdornment.ZIndex = 0
            boxAdornment.AlwaysOnTop = true
            boxAdornment.Adornee = hrp
            boxAdornment.Parent = espFolder

            local tracer = Instance.new("Frame")
            tracer.Name = plr.Name .. "_Tracer"
            tracer.AnchorPoint = Vector2.new(0.5, 0.5)
            tracer.Size = UDim2.new(0, 2, 0, 80)
            tracer.BackgroundColor3 = getTeamColorForPlayer(plr)
            tracer.BorderSizePixel = 0
            tracer.Visible = false
            tracer.Parent = espFolder

            local tracerCorner = Instance.new("UICorner")
            tracerCorner.CornerRadius = UDim.new(1, 0)
            tracerCorner.Parent = tracer

            local function updateInfo()
                local myR = getRoot()
                if myR and hrp then
                    distance = math.floor((hrp.Position - myR.Position).Magnitude)
                    if MiscState.ESPNameDist then
                        infoLabel.Text = "Dist: " .. distance .. " studs"
                    else
                        infoLabel.Text = ""
                    end
                end

                if hum then
                    local hp = math.floor(hum.Health)
                    local mh = math.floor(hum.MaxHealth)
                    if MiscState.ESPHealth then
                        healthLabel.Text = "HP: " .. hp .. "/" .. mh

                        local ratio = (mh > 0) and (hp / mh) or 0
                        if ratio > 0.6 then
                            healthLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
                        elseif ratio > 0.3 then
                            healthLabel.TextColor3 = Color3.fromRGB(255, 220, 90)
                        else
                            healthLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
                        end
                    else
                        healthLabel.Text = ""
                    end
                else
                    healthLabel.Text = ""
                end

                nameLabel.Visible = MiscState.ESPNameDist

                local col = getTeamColorForPlayer(plr)
                stroke.Color = col
                boxAdornment.Color3 = col
                tracer.BackgroundColor3 = col

                boxAdornment.Visible = MiscState.ESPBox

                local cam = workspace.CurrentCamera
                if cam and MiscState.ESPTracers and hrp and plr.Character then
                    local rootPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        tracer.Visible = true
                        tracer.Position = UDim2.new(0, rootPos.X, 1, 0)
                        tracer.Size = UDim2.new(0, 2, 0, math.clamp(cam.ViewportSize.Y - rootPos.Y, 0, 400))
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end

                billboard.Enabled = MiscState.ESP
            end

            updateInfo()

            Services.RunService.Heartbeat:Connect(function()
                if not MiscState.ESP or not plr.Parent then
                    billboard.Enabled = false
                    tracer.Visible = false
                    if not plr.Parent then
                        billboard:Destroy()
                        boxAdornment:Destroy()
                        tracer:Destroy()
                    end
                    return
                end
                char = plr.Character
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                hum = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hrp then
                    billboard.Enabled = false
                    boxAdornment.Adornee = nil
                    tracer.Visible = false
                    return
                end
                boxAdornment.Adornee = hrp
                updateInfo()
            end)
        end

        local function refreshESP()
            clearESP()
            if not MiscState.ESP then return end
            for _, plr in ipairs(Services.Players:GetPlayers()) do
                createESPForPlayer(plr)
            end
        end

        Services.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(1)
                if MiscState.ESP then createESPForPlayer(plr) end
            end)
        end)

        Services.Players.PlayerRemoving:Connect(function(plr)
            for _, v in ipairs(espFolder:GetChildren()) do
                if v.Name:match("^" .. plr.Name) then
                    v:Destroy()
                end
            end
        end)

        local function setInvisibility(enabled)
            local char = LocalPlayer.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if enabled then
                    MiscState.OrigName[hum] = { hum.DisplayDistanceType, hum.NameDisplayDistance }
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    hum.NameDisplayDistance = 0
                elseif MiscState.OrigName[hum] then
                    hum.DisplayDistanceType = MiscState.OrigName[hum][1]
                    hum.NameDisplayDistance = MiscState.OrigName[hum][2]
                end
            end

            for _, o in ipairs(char:GetDescendants()) do
                if o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture") or o:IsA("MeshPart") then
                    if enabled then
                        if MiscState.OrigTrans[o] == nil then
                            MiscState.OrigTrans[o] = o.Transparency
                        end
                        o.Transparency = 1
                    else
                        if MiscState.OrigTrans[o] ~= nil then
                            o.Transparency = MiscState.OrigTrans[o]
                        end
                    end
                end
            end

            if not enabled then
                MiscState.OrigTrans = {}
            end
        end

        LocalPlayer.CharacterAdded:Connect(function(char)
            if MiscState.Invis then
                char:WaitForChild("Humanoid", 10)
                task.delay(1, function() setInvisibility(true) end)
            end
        end)

        local function enableFPSBoost()
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            Services.Lighting.GlobalShadows = false
            Services.Lighting.FogEnd = 9e9
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    if not v.Parent:IsA("SurfaceGui") then
                        v.Transparency = 1
                    end
                end
            end
        end

        local function disableFPSBoost()
            Services.Lighting.GlobalShadows = true
        end

        Services.RunService.Heartbeat:Connect(function()
            if MiscState.Freeze and MiscState.FrozenCF then
                local r = getRoot()
                if r then
                    r.CFrame = MiscState.FrozenCF
                    r.Velocity = Vector3.new()
                end
            end
        end)

        -----------------------------------------------------------------
        -- PERSONAL ANTI-FLING
        -----------------------------------------------------------------
        local MaxVel  = 120
        local MaxVert = 80

        Services.RunService.Heartbeat:Connect(function()
            local r = getRoot()
            if not r then return end
            local v = r.Velocity
            if v.Magnitude > MaxVel then
                v = v.Unit * MaxVel
            end
            v = Vector3.new(v.X, math.clamp(v.Y, -MaxVert, MaxVert), v.Z)
            r.Velocity = v
            r.AssemblyLinearVelocity = v
        end)

        -----------------------------------------------------------------
        -- KEYBINDS STORAGE (USED BY RAYFIELD)
        -----------------------------------------------------------------
        local keybinds = {
            RingParts      = Enum.KeyCode.R,
            Flight         = Enum.KeyCode.F,
            Godmode        = Enum.KeyCode.G,
            Menu           = Enum.KeyCode.P,
            Noclip         = Enum.KeyCode.N,
            Teleport       = Enum.KeyCode.T,
            RandomTeleport = Enum.KeyCode.Y
        }

        local function keycodeToString(code)
            return code and code.Name or "None"
        end

        -----------------------------------------------------------------
        -- BLACKHOLE SYSTEM (IMPROVED)
        -----------------------------------------------------------------
        local Blackhole = {
            Enabled     = false,
            Radius      = 100,
            PullForce   = 3500,
            VerticalPull= 120,
            CenterMode  = "Player", -- Player / Cursor
            CenterPart  = nil,
            Cooldown    = 0.05,
            LastTime    = 0,
            DestroyCore = true
        }

        local function getBlackholeCenter()
            local root = getRoot()
            if Blackhole.CenterMode == "Cursor" then
                local cam = workspace.CurrentCamera
                local mouse = LocalPlayer:GetMouse()
                if cam and mouse then
                    local unitRay = cam:ScreenPointToRay(mouse.X, mouse.Y)
                    local origin = unitRay.Origin
                    local dir = unitRay.Direction * 200
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    local result = workspace:Raycast(origin, dir, raycastParams)
                    if result then
                        return result.Position
                    else
                        return origin + dir
                    end
                end
            end
            return root and root.Position or Vector3.new()
        end

        Services.RunService.Heartbeat:Connect(function()
            if not Blackhole.Enabled then return end
            local now = tick()
            if now - Blackhole.LastTime < Blackhole.Cooldown then return end
            Blackhole.LastTime = now

            local centerPos = getBlackholeCenter()
            local parts = getNearbyParts(centerPos, Blackhole.Radius)

            for _, p in ipairs(parts) do
                if p:IsA("BasePart") and not p:IsDescendantOf(LocalPlayer.Character) then
                    if Blackhole.DestroyCore and (p.Name:lower():find("spawn") or p.Name:lower():find("baseplate")) then
                        p.Anchored = false
                    end

                    preparePhysicsPart(p)

                    local offset = centerPos - p.Position
                    local dist = offset.Magnitude
                    if dist < 1 then dist = 1 end
                    local dir = offset.Unit

                    local pull = dir * Blackhole.PullForce
                    pull = Vector3.new(
                        math.clamp(pull.X, -2200, 2200),
                        math.clamp(pull.Y + Blackhole.VerticalPull, -Blackhole.VerticalPull, Blackhole.VerticalPull),
                        math.clamp(pull.Z, -2200, 2200)
                    )

                    local newVel = p.Velocity + pull
                    newVel = Vector3.new(
                        math.clamp(newVel.X, -650, 650),
                        math.clamp(newVel.Y, -Blackhole.VerticalPull, Blackhole.VerticalPull),
                        math.clamp(newVel.Z, -650, 650)
                    )

                    p.Velocity = newVel
                    p.AssemblyLinearVelocity = newVel
                end
            end
        end)

        -----------------------------------------------------------------
        -- MAP DESTRUCTION SYSTEM (IMPROVED & TIED TO NETWORK)
        -----------------------------------------------------------------
        local MapDestruction = {
            CurrentMapName = "",
            KnownMaps = {
                "Heights School",
                "Launch Land",
                "Surf Central",
                "Sky Tower",
                "Modest Headquarters",
                "Glass Office",
                "Raving Raceway",
                "Trailer Park",
                "Lucky Mart",
                "Prison Panic",
                "Party Palace",
                "Coastal Quickstop",
                "Fort Indestructible",
                "Rainbow Ride",
                "Deadly Decisions"
            }
        }

        local function findCurrentMapModel()
            local best
            for _, inst in ipairs(workspace:GetChildren()) do
                if inst:IsA("Model") then
                    local name = inst.Name:lower()
                    if not name:find("lobby") and not name:find("baseplate") and not name:find("spawn") then
                        best = inst
                        break
                    end
                end
            end
            return best
        end

        local function destroyWholeModel(model)
            if not model then return 0 end
            local count = 0
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    preparePhysicsPart(obj)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Color = Color3.fromRGB(0, 0, 0)

                    local v = Vector3.new(math.random(-600,600), math.random(250,500), math.random(-600,600))
                    obj.Velocity = v
                    obj.AssemblyLinearVelocity = v
                    count += 1
                end
            end
            return count
        end

        local function destroyEntireMap()
            local mapModel = findCurrentMapModel()
            local total = 0

            if mapModel then
                total = destroyWholeModel(mapModel)
            end

            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Model") and inst.Name:lower():find("map") then
                    total = total + destroyWholeModel(inst)
                end
            end

            return total
        end

        -----------------------------------------------------------------
        -- RAYFIELD TABS & WIDGETS
        -----------------------------------------------------------------

        -- MAIN / RING TAB
        local RingTab = Window:CreateTab("Anel de Partes", 4483362458)

        RingTab:CreateSection("Controle do Anel")

        RingTab:CreateToggle({
            Name = "Anel de Partes",
            CurrentValue = false,
            Callback = function(Value)
                Ring.Enabled = Value
                playSound("12221967")
            end
        })

        RingTab:CreateSlider({
            Name = "Raio",
            Range = {10, 200},
            Increment = 5,
            CurrentValue = Ring.Radius,
            Callback = function(Value)
                Ring.Radius = Value
                playSound("12221967")
            end
        })

        RingTab:CreateSlider({
            Name = "Raio Interno",
            Range = {2, 20},
            Increment = 1,
            CurrentValue = Ring.MinDist,
            Callback = function(Value)
                Ring.MinDist = Value
                playSound("12221967")
            end
        })

        RingTab:CreateSlider({
            Name = "Deslocamento de Altura",
            Range = {0, 20},
            Increment = 1,
            CurrentValue = Ring.HeightOffset,
            Callback = function(Value)
                Ring.HeightOffset = Value
                playSound("12221967")
            end
        })

        RingTab:CreateSlider({
            Name = "Força do Anel",
            Range = {200, 2500},
            Increment = 100,
            CurrentValue = Ring.Force,
            Callback = function(Value)
                Ring.Force = Value
                playSound("12221967")
            end
        })

        RingTab:CreateSlider({
            Name = "Velocidade do Anel",
            Range = {1, 24},
            Increment = 1,
            CurrentValue = Ring.Speed,
            Callback = function(Value)
                Ring.Speed = Value
                Ring.RotSpeed = Value
                playSound("12221967")
            end
        })

        RingTab:CreateDropdown({
            Name = "Padrão",
            Options = {"Orbit","Vertical","Wave","Sphere","SpherePulsing","Chaos","Spiral","Helix","Pulse","RandomShell"},
            CurrentOption = {Ring.Pattern},
            MultipleOptions = false,
            Callback = function(Option)
                Ring.Pattern = Option[1]
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- FLIGHT TAB
        -----------------------------------------------------------------
        local FlightTab = Window:CreateTab("Voo", 4483362458)

        FlightTab:CreateSection("Controle de Voo")

        FlightTab:CreateToggle({
            Name = "Voo",
            CurrentValue = false,
            Callback = function(Value)
                if Value then
                    startFlight()
                else
                    stopFlight()
                end
            end
        })

        FlightTab:CreateSlider({
            Name = "Velocidade de Voo",
            Range = {10, 300},
            Increment = 5,
            CurrentValue = Movement.FlightSpeed,
            Callback = function(Value)
                Movement.FlightSpeed = Value
                playSound("12221967")
            end
        })

        FlightTab:CreateSlider({
            Name = "Velocidade de Caminhada",
            Range = {8, 200},
            Increment = 2,
            CurrentValue = Movement.BaseWalk,
            Callback = function(Value)
                Movement.BaseWalk = Value
                applyMovementStats()
                playSound("12221967")
            end
        })

        FlightTab:CreateSlider({
            Name = "Força do Pulo",
            Range = {20, 300},
            Increment = 5,
            CurrentValue = Movement.BaseJump,
            Callback = function(Value)
                Movement.BaseJump = Value
                applyMovementStats()
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- GODMODE TAB
        -----------------------------------------------------------------
        local GodTab = Window:CreateTab("Modo Deus", 4483362458)
        GodTab:CreateSection("Controle do Modo Deus")

        GodTab:CreateToggle({
            Name = "Modo Deus",
            CurrentValue = false,
            Callback = function(Value)
                God.Enabled = Value
                if God.Enabled then
                    if LocalPlayer.Character then
                        enableGodOnChar(LocalPlayer.Character)
                    end
                else
                    disableGod()
                end
                playSound("12221967")
            end
        })

        GodTab:CreateSlider({
            Name = "Limite de Cura Automática %",
            Range = {God.MinHeal, God.MaxHeal},
            Increment = 5,
            CurrentValue = God.HealThresh,
            Callback = function(Value)
                God.HealThresh = Value
                playSound("12221967")
            end
        })

        GodTab:CreateSlider({
            Name = "Vida Máxima",
            Range = {God.MinMaxHP, God.MaxMaxHP},
            Increment = 50,
            CurrentValue = Movement.BaseMaxHP,
            Callback = function(Value)
                Movement.BaseMaxHP = Value
                playSound("12221967")
            end
        })

        GodTab:CreateToggle({
            Name = "Anti-Dano de Queda",
            CurrentValue = God.AntiFall,
            Callback = function(Value)
                God.AntiFall = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- ADVANCED / NOCLIP TAB
        -----------------------------------------------------------------
        local AdvancedTab = Window:CreateTab("Avançado", 4483362458)

        AdvancedTab:CreateSection("Movimento e Utilidades")

        AdvancedTab:CreateToggle({
            Name = "Atravessar Paredes",
            CurrentValue = false,
            Callback = function(Value)
                Noclip.Enabled = Value
                if not Value then
                    setCharCollide(LocalPlayer.Character, true)
                end
                playSound("12221967")
            end
        })

        AdvancedTab:CreateToggle({
            Name = "Anti-Ausente",
            CurrentValue = false,
            Callback = function(Value)
                AntiAFK.Enabled = Value
                playSound("12221967")

                if AntiAFK.Enabled then
                    if AntiAFK.Conn then AntiAFK.Conn:Disconnect() end
                    local vu = game:GetService("VirtualUser")
                    AntiAFK.Conn = LocalPlayer.Idled:Connect(function()
                        vu:Button2Down(Vector2.new(), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                        task.wait(1)
                        vu:Button2Up(Vector2.new(), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                    end)
                else
                    if AntiAFK.Conn then AntiAFK.Conn:Disconnect() AntiAFK.Conn = nil end
                end
            end
        })

        AdvancedTab:CreateToggle({
            Name = "Reconectar Automático",
            CurrentValue = false,
            Callback = function(Value)
                AutoRejoin.Enabled = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- TELEPORT TAB
        -----------------------------------------------------------------
        local TeleportTab = Window:CreateTab("Teleporte", 4483362458)

        TeleportTab:CreateSection("Modo e Alvo")

        TeleportTab:CreateDropdown({
            Name = "Modo de Teleporte",
            Options = {"ToPlayer","ToLobby","Smooth"},
            CurrentOption = {TP.Mode},
            MultipleOptions = false,
            Callback = function(Option)
                TP.Mode = Option[1]
                playSound("12221967")
            end
        })

        TeleportTab:CreateDropdown({
            Name = "Selecionar Jogador",
            Options = (function()
                local list = {}
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= LocalPlayer then table.insert(list, plr.Name) end
                end
                return list
            end)(),
            CurrentOption = {},
            MultipleOptions = false,
            Callback = function(Option)
                local name = Option[1]
                local plr = Services.Players:FindFirstChild(name)
                if plr then
                    TP.Target = plr
                    if TP.Mode == "ToLobby" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        TP.LobbyCFrame = plr.Character.HumanoidRootPart.CFrame
                    end
                end
                playSound("12221967")
            end
        })

        TeleportTab:CreateButton({
            Name = "Teleportar para Alvo",
            Callback = function()
                teleportToTarget()
            end
        })

        TeleportTab:CreateButton({
            Name = "Teleportar Novamente",
            Callback = function()
                if TP.Target then
                    teleportToTarget()
                end
            end
        })

        TeleportTab:CreateButton({
            Name = "Teleportar para Jogador Aleatório",
            Callback = function()
                randomTeleport()
            end
        })

        TeleportTab:CreateSection("Segurança e Seguir")

        TeleportTab:CreateSlider({
            Name = "Raio de Segurança",
            Range = {1, 10},
            Increment = 1,
            CurrentValue = TP.SafeRadius,
            Callback = function(Value)
                TP.SafeRadius = Value
                playSound("12221967")
            end
        })

        TeleportTab:CreateSlider({
            Name = "Deslocamento Lateral",
            Range = {0, 10},
            Increment = 0.5,
            CurrentValue = TP.SideOffset,
            Callback = function(Value)
                TP.SideOffset = Value
                playSound("12221967")
            end
        })

        TeleportTab:CreateToggle({
            Name = "Seguir Alvo Automaticamente",
            CurrentValue = TP.AutoFollow,
            Callback = function(Value)
                TP.AutoFollow = Value
                if not TP.AutoFollow then
                    TP.Orbit = false
                end
                playSound("12221967")
            end
        })

        TeleportTab:CreateToggle({
            Name = "Orbitar Alvo (requer Seguir Auto)",
            CurrentValue = TP.Orbit,
            Callback = function(Value)
                if not TP.AutoFollow then
                    playSound("12221967")
                    return
                end
                TP.Orbit = Value
                playSound("12221967")
            end
        })

        TeleportTab:CreateToggle({
            Name = "Ficar Acima do Alvo",
            CurrentValue = TP.StayAbove,
            Callback = function(Value)
                TP.StayAbove = Value
                playSound("12221967")
            end
        })

        TeleportTab:CreateToggle({
            Name = "Ajustar Altura",
            CurrentValue = TP.SnapHeight,
            Callback = function(Value)
                TP.SnapHeight = Value
                playSound("12221967")
            end
        })

        TeleportTab:CreateSlider({
            Name = "Deslocamento de Altura Extra",
            Range = {-20, 20},
            Increment = 1,
            CurrentValue = TP.OffsetUp,
            Callback = function(Value)
                TP.OffsetUp = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- MISC TAB
        -----------------------------------------------------------------
        local MiscTab = Window:CreateTab("Diversos", 4483362458)

        MiscTab:CreateSection("Visibilidade e FPS")

        MiscTab:CreateToggle({
            Name = "Invisibilidade",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.Invis = Value
                setInvisibility(Value)
                playSound("12221967")
            end
        })

        MiscTab:CreateToggle({
            Name = "Aumentar FPS",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.FPSBoost = Value
                if Value then
                    enableFPSBoost()
                else
                    disableFPSBoost()
                end
                playSound("12221967")
            end
        })

        MiscTab:CreateToggle({
            Name = "Congelar Posição",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.Freeze = Value
                if Value then
                    local r = getRoot()
                    if r then MiscState.FrozenCF = r.CFrame end
                end
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- ESP TAB
        -----------------------------------------------------------------
        local ESPTab = Window:CreateTab("ESP", 4483362458)

        ESPTab:CreateSection("ESP Principal")

        ESPTab:CreateToggle({
            Name = "ESP Principal",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.ESP = Value
                playSound("12221967")
                refreshESP()
            end
        })

        ESPTab:CreateToggle({
            Name = "Caixas",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.ESPBox = Value
                playSound("12221967")
            end
        })

        ESPTab:CreateToggle({
            Name = "Texto de Vida",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.ESPHealth = Value
                playSound("12221967")
            end
        })

        ESPTab:CreateToggle({
            Name = "Nome / Distância",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.ESPNameDist = Value
                playSound("12221967")
            end
        })

        ESPTab:CreateToggle({
            Name = "Rastreadores",
            CurrentValue = false,
            Callback = function(Value)
                MiscState.ESPTracers = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- DESTRUCTIVE AURA TAB (UI)
        -----------------------------------------------------------------
        local AuraTab = Window:CreateTab("Aura Destrutiva", 4483362458)

        AuraTab:CreateSection("Controle da Aura")

        AuraTab:CreateToggle({
            Name = "Aura Destrutiva",
            CurrentValue = false,
            Callback = function(Value)
                Aura.Enabled = Value
                playSound("12221967")
            end
        })

        AuraTab:CreateToggle({
            Name = "Quebrar Construções / Coletar Destroços",
            CurrentValue = false,
            Callback = function(Value)
                Aura.BreakEnabled = Value
                playSound("12221967")
            end
        })

        AuraTab:CreateSlider({
            Name = "Raio da Aura",
            Range = {20, 120},
            Increment = 5,
            CurrentValue = Aura.Radius,
            Callback = function(Value)
                Aura.Radius = Value
                playSound("12221967")
            end
        })

        AuraTab:CreateSlider({
            Name = "Força da Aura",
            Range = {500, 4000},
            Increment = 100,
            CurrentValue = Aura.Force,
            Callback = function(Value)
                Aura.Force = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- BLACKHOLE TAB (NEW)
        -----------------------------------------------------------------
        local BlackTab = Window:CreateTab("Buraco Negro", 4483362458)

        BlackTab:CreateSection("Controle do Buraco Negro")

        BlackTab:CreateToggle({
            Name = "Ativar Buraco Negro",
            CurrentValue = false,
            Callback = function(Value)
                Blackhole.Enabled = Value
                playSound("12221967")
            end
        })

        BlackTab:CreateDropdown({
            Name = "Modo de Centro",
            Options = {"Jogador","Cursor"},
            CurrentOption = {Blackhole.CenterMode},
            MultipleOptions = false,
            Callback = function(opt)
                Blackhole.CenterMode = opt[1]
                playSound("12221967")
            end
        })

        BlackTab:CreateSlider({
            Name = "Raio do Buraco Negro",
            Range = {30, 200},
            Increment = 5,
            CurrentValue = Blackhole.Radius,
            Callback = function(Value)
                Blackhole.Radius = Value
                playSound("12221967")
            end
        })

        BlackTab:CreateSlider({
            Name = "Força de Atração",
            Range = {500, 6000},
            Increment = 100,
            CurrentValue = Blackhole.PullForce,
            Callback = function(Value)
                Blackhole.PullForce = Value
                playSound("12221967")
            end
        })

        BlackTab:CreateSlider({
            Name = "Limite de Atração Vertical",
            Range = {40, 250},
            Increment = 5,
            CurrentValue = Blackhole.VerticalPull,
            Callback = function(Value)
                Blackhole.VerticalPull = Value
                playSound("12221967")
            end
        })

        BlackTab:CreateToggle({
            Name = "Tentar Destruir Núcleo (Spawn/Base)",
            CurrentValue = Blackhole.DestroyCore,
            Callback = function(Value)
                Blackhole.DestroyCore = Value
                playSound("12221967")
            end
        })

        -----------------------------------------------------------------
        -- MAP DESTRUCTION TAB (UPDATED)
        -----------------------------------------------------------------
        local MapTab = Window:CreateTab("Destruir Mapa", 4483362458)

        MapTab:CreateSection("Destruir Mapa Inteiro")

        MapTab:CreateButton({
            Name = "Destruir Mapa Atual (Brutal)",
            Callback = function()
                local total = destroyEntireMap()
                playSound("12221967")
                pcall(function()
                    Services.StarterGui:SetCore("SendNotification", {
                        Title = "❄ Winter Hub",
                        Text = "Destruídas ~" .. tostring(total) .. " partes no mapa atual.",
                        Duration = 4
                    })
                end)
            end
        })

        MapTab:CreateDropdown({
            Name = "Mapas Conhecidos (para info)",
            Options = MapDestruction.KnownMaps,
            CurrentOption = {},
            MultipleOptions = false,
            Callback = function(opt)
                MapDestruction.CurrentMapName = opt[1]
                playSound("12221967")
            end
        })

        MapTab:CreateButton({
            Name = "Tentar Destruir Todos os Modelos do Mapa",
            Callback = function()
                local total = 0
                for _, inst in ipairs(workspace:GetChildren()) do
                    if inst:IsA("Model") then
                        if not inst.Name:lower():find("lobby") and not inst.Name:lower():find("baseplate") then
                            total = total + destroyWholeModel(inst)
                        end
                    end
                end
                playSound("12221967")
                pcall(function()
                    Services.StarterGui:SetCore("SendNotification", {
                        Title = "❄ Winter Hub",
                        Text = "Destruição brutal do mapa: ~" .. tostring(total) .. " partes atingidas.",
                        Duration = 4
                    })
                end)
            end
        })

        -----------------------------------------------------------------
        -- KEYBINDS TAB (RAYFIELD KEYBINDS)
        -----------------------------------------------------------------
        local KeybindsTab = Window:CreateTab("Atalhos", 4483362458)

        KeybindsTab:CreateSection("Atalhos de Alternância")

        KeybindsTab:CreateKeybind({
            Name = "Alternar Anel de Partes",
            CurrentKeybind = keybinds.RingParts,
            HoldToInteract = false,
            Flag = "RingPartsBind",
            Callback = function(Key)
                keybinds.RingParts = Key
                Ring.Enabled = not Ring.Enabled
                playSound("12221967")
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Alternar Voo",
            CurrentKeybind = keybinds.Flight,
            HoldToInteract = false,
            Flag = "FlightBind",
            Callback = function(Key)
                keybinds.Flight = Key
                if Movement.Flying then
                    stopFlight()
                else
                    startFlight()
                end
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Alternar Modo Deus",
            CurrentKeybind = keybinds.Godmode,
            HoldToInteract = false,
            Flag = "GodBind",
            Callback = function(Key)
                keybinds.Godmode = Key
                God.Enabled = not God.Enabled
                if God.Enabled then
                    if LocalPlayer.Character then enableGodOnChar(LocalPlayer.Character) end
                else
                    disableGod()
                end
                playSound("12221967")
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Alternar Visibilidade do Menu",
            CurrentKeybind = keybinds.Menu,
            HoldToInteract = false,
            Flag = "MenuBind",
            Callback = function(Key)
                keybinds.Menu = Key
                Window:Toggle()
                playSound("12221967")
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Alternar Atravessar Paredes",
            CurrentKeybind = keybinds.Noclip,
            HoldToInteract = false,
            Flag = "NoclipBind",
            Callback = function(Key)
                keybinds.Noclip = Key
                Noclip.Enabled = not Noclip.Enabled
                if not Noclip.Enabled then
                    setCharCollide(LocalPlayer.Character, true)
                end
                playSound("12221967")
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Teleportar para Alvo",
            CurrentKeybind = keybinds.Teleport,
            HoldToInteract = false,
            Flag = "TeleportBind",
            Callback = function(Key)
                keybinds.Teleport = Key
                teleportToTarget()
            end
        })

        KeybindsTab:CreateKeybind({
            Name = "Teleporte Aleatório",
            CurrentKeybind = keybinds.RandomTeleport,
            HoldToInteract = false,
            Flag = "RandomTpBind",
            Callback = function(Key)
                keybinds.RandomTeleport = Key
                randomTeleport()
            end
        })

        -----------------------------------------------------------------
        -- NOTIFICATIONS
        -----------------------------------------------------------------
        pcall(function()
            Services.StarterGui:SetCore("SendNotification", {
                Title = "❄ Winter Hub Carregado",
                Text = "Winter Hub de Desastres Naturais [V4.3] (Rayfield UI)",
                Duration = 5
            })
        end)

        pcall(function()
            local uid = Services.Players:GetUserIdFromNameAsync("Kl_Kyiru")
            if uid then
                local thumbType = Enum.ThumbnailType.HeadShot
                local thumbSize = Enum.ThumbnailSize.Size420x420
                local content
                pcall(function()
                    content = (select(1, Services.Players:GetUserThumbnailAsync(uid, thumbType, thumbSize)))
                end)
                if content then
                    pcall(function()
                        Services.StarterGui:SetCore("SendNotification", {
                            Title = "❄ Aproveite o Winter Hub",
                            Text = "Aproveite o Winter Hub!",
                            Icon = content,
                            Duration = 5
                        })
                    end)
                end
            end
        end)
    end)
