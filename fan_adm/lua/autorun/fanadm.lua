fadm                = fadm or {}; adm = fadm; admin = fadm
fadm.version        = 'unreleased'
fadm.version_date   = '06.12.2023'--'01.05.2022' / start - '02.12.2023' - full recode

function fadm:print(...)
    tag=tag or "[ADMIN]"
    MsgC(Color(255,0,0), tag .." ", Color(255,255,255), ...)
    Msg("\n")
end

function fadm:FileSide(file)
    if string.find(file, "cl_") || string.find(file, "_cl") || string.find(file, "client_") || string.find(file, "_client") then
        return "cl"
    end
    if string.find(file, "sv_") || string.find(file, "_sv") || string.find(file, "server_") || string.find(file, "_server") then
        return "sv"
    end
    return "sh"
end

fadm.loaded_files={0,0}
function fadm:Include(path, side, data)
    data = data || {}
    if side ~= "dir" && side ~= "~" then 
        self.loaded_files[1] = self.loaded_files[1] + 1 
    elseif side == "dir" then
        fadm.loaded_files[2] = fadm.loaded_files[2] + 1
    end

    if side == "~" then
        return self:Include(path, self:FileSide(path))
    end

    if side == "sv" then
        if SERVER then
            self:print('including: "'.. path ..'" | server')
            return include(path)
        end
    end

    if side == "cl" then
        self:print('including: "'.. path ..'" | client')
        if SERVER then
            AddCSLuaFile(path)
            return "ok"
        end
        if CLIENT then
            return include(path)
        end
    end

    if side == "dir" then
        local f,d = file.Find(path .."/*", "LUA")
        local a,b = true,true
        self:print(string.format('including: "%s" | f(%s):%s d(%s):%s | path', path, tostring(#f), tostring(a), tostring(#d), tostring(b)),FADM_SOMEONE)
        if data.only then
            if data.only=="files" then
                b=false
            end
            if data.only=="dirs" then
                a=false
            end
        end
        if a then
            for k,v in pairs(f) do
                self:Include(path .. "/" .. v, "~", data)
            end
        end
        if b then
            for k,v in pairs(d) do
                self:Include(path .. "/" .. v, "dir", data)
            end
        end

        return
    end

    self:print('including: "'.. path ..'" | all')
    if SERVER then
        AddCSLuaFile(path)
    end
    return include(path)
end

fadm:Include("fanadmin/load.lua","sh")
