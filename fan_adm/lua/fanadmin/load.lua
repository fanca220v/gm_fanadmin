if not fadm then
    MsgC(Color(255,0,0),'fan admin is dead\n')
    return
end


-- fadm.default_cfg = fadm:Include("cfg.lua")
fadm:Include("fanadmin/core",   "dir")
fadm:Include("fanadmin/config", "dir")
fadm:Include("fanadmin/cmds",   "dir")

fadm:Include("fadm_sync",       "dir")

fadm:print('full loaded <3 / '.. tostring(fadm.loaded_files[1]) .." files / ".. tostring(fadm.loaded_files[2]) .." dirs")
fadm.util:OnInitilized(function(self)
    local ver_txt = 'version: "'.. self.version ..'" | '.. self.version_date
    local center_img = "                    "
    -- print(#ver_txt, #center_img)
    center_img = string.sub(center_img, #ver_txt /2, #center_img)

    self:print("\n\n\n".. [[
               FAN ADMIN
      developer:@fanca01 (vk,steam)
        ########################
        ########################
        ######## ####  ###  ####
        #######  ###   ###  ####
        #######  ###  ###  #####
        ######  ###  ####  #####
        #####   ###  ###  ######
        #####  ###  ###   ######
        ####  ####  ###  #######
        ####  ###  ###  ########
        ########################
        ########################
]].. center_img .. ver_txt .."\n\n\n")
    self:print("server load time: ".. string.sub(tostring(SysTime()), 1, 5) .."sec")
end)