------------------------------------------------------------------------------------------------
-- INFINITE AMMO MOD
------------------------------------------------------------------------------------------------

local EnableModule   = 2        -- 1: infinite ammo always - 2: equip infinite ammo item
local AnnounceModule = 1        -- Announce module on player login (if EnableModule=1)

local ItemEntry      = 38059    -- Infinite Ammo Bag

------------------------------------------------------------------------------------------------
-- END CONFIG
------------------------------------------------------------------------------------------------

if (EnableModule ~= 1 and EnableModule ~= 2) then return end

require("ObjectVariables")
local FILE_NAME = string.match(debug.getinfo(1,'S').source, "[^/\\]*.lua$")

-- spellid.ammocount
local HUNTER_SPELLS = {
    {75, 1}, -- Auto Shot
    {3044, 1}, -- Arcane Shot (Rank 1)
    {14281, 1}, -- Arcane Shot (Rank 2)
    {14282, 1}, -- Arcane Shot (Rank 3)
    {14283, 1}, -- Arcane Shot (Rank 4)
    {14284, 1}, -- Arcane Shot (Rank 5)
    {14285, 1}, -- Arcane Shot (Rank 6)
    {14286, 1}, -- Arcane Shot (Rank 7)
    {14287, 1}, -- Arcane Shot (Rank 8)
    {5116, 1}, -- Concussive Shot
    {20736, 1}, -- Distracting Shot (Rank 1)
    {2643, 1}, -- Multi-Shot (Rank 1)
    {14288, 1}, -- Multi-Shot (Rank 2)
    {14289, 1}, -- Multi-Shot (Rank 3)
    {14290, 1}, -- Multi-Shot (Rank 4)
    {25294, 1}, -- Multi-Shot (Rank 5)
    {3043, 1}, -- Scorpid Sting
    {1978, 1}, -- Serpent Sting (Rank 1)
    {13549, 1}, -- Serpent Sting (Rank 2)
    {13550, 1}, -- Serpent Sting (Rank 3)
    {13551, 1}, -- Serpent Sting (Rank 4)
    {13552, 1}, -- Serpent Sting (Rank 5)
    {13553, 1}, -- Serpent Sting (Rank 6)
    {13554, 1}, -- Serpent Sting (Rank 7)
    {13555, 1}, -- Serpent Sting (Rank 8)
    {25295, 1}, -- Serpent Sting (Rank 9)
    {19801, 1}, -- Tranquilizing Shot
    {3034, 1}, -- Viper Sting
    {1510, 2}, -- Volley (Rank 1)
    {14294, 2}, -- Volley (Rank 2)
    {14295, 2}, -- Volley (Rank 3)
    {19434, 1}, -- Aimed Shot (Rank 1)
    {20900, 1}, -- Aimed Shot (Rank 2)
    {20901, 1}, -- Aimed Shot (Rank 3)
    {20902, 1}, -- Aimed Shot (Rank 4)
    {20903, 1}, -- Aimed Shot (Rank 5)
    {20904, 1}, -- Aimed Shot (Rank 6)
    {27065, 1}, -- Aimed Shot (Rank 7)
    {49049, 1}, -- Aimed Shot (Rank 8)
    {49050, 1}, -- Aimed Shot (Rank 9)
    {53209, 1}, -- Chimera Shot (Rank 1)
    {34490, 1}, -- Silencing Shot
    {19503, 1}, -- Scatter Shot
    {19386, 1}, -- Wyvern String (Rank 1)
    {24132, 1}, -- Wyvern String (Rank 2)
    {24133, 1}, -- Wyvern String (Rank 3)
    {27068, 1}, -- Wyvern String (Rank 4)
    {49011, 1}, -- Wyvern String (Rank 5)
    {49012, 1}, -- Wyvern String (Rank 6)
    {3674, 1}, -- Black Arrow (Rank 1)
    {63668, 1}, -- Black Arrow (Rank 2)
    {63669, 1}, -- Black Arrow (Rank 3)
    {63670, 1}, -- Black Arrow (Rank 4)
    {63671, 1}, -- Black Arrow (Rank 5)
    {63672, 1}, -- Black Arrow (Rank 6)
    {53301, 1}, -- Explosive Shot (Rank 1)
    {60051, 1}, -- Explosive Shot (Rank 2)
    {60052, 1}, -- Explosive Shot (Rank 3)
    {60053, 1}, -- Explosive Shot (Rank 4)
}
local SPELL_SHOOT = 3018

local PLAYER_AMMO_ID = 0x4AE
local CLASS_WARRIOR = 1
local CLASS_HUNTER = 3
local CLASS_ROGUE = 4

local function hasInfiniteBag(player)
    for i=19,22 do
        local bag = player:GetItemByPos(255,i)
        if (bag and bag:GetEntry() == ItemEntry) then
            return true
        end
    end
    return false
end

local function onSpellCast(event, player, spell)
    local class = player:GetClass()
    if (class == CLASS_WARRIOR or class == CLASS_ROGUE or class == CLASS_HUNTER) then
        if (EnableModule==1 or hasInfiniteBag(player)) then
            local amount = 0
            if (class == CLASS_WARRIOR or class == CLASS_ROGUE) then
                if (spell:GetEntry() == SPELL_SHOOT) then
                    amount = 1
                end
            elseif (class == CLASS_HUNTER) then
                local spellId = spell:GetEntry()
                for _, v in ipairs(HUNTER_SPELLS) do
                    if (v[1] == spellId) then
                        amount = v[2]
                        break
                    end
                end
            end
            if(amount > 0) then
                local ammoID = player:GetUInt32Value(PLAYER_AMMO_ID)
                if (ammoID) then
                    player:SetData("_skip_ammo_msg", ammoID)
                    player:AddItem(ammoID, amount)
                end
            end
        end
    end
end

local function onSendItemPushResult(event, packet, player)
    local ammoID = player:GetData("_skip_ammo_msg")
    if(ammoID) then
        local guid = packet:ReadGUID()
        local received = packet:ReadULong()
        local created = packet:ReadULong()
        local sendChatMessage = packet:ReadULong()
        local bagslot = packet:ReadUByte()
        local itemslot = packet:ReadULong()
        local itemid = packet:ReadULong()
        local suffixfactor = packet:ReadULong()
        local randompropertyid = packet:ReadLong()
        local count = packet:ReadULong()
        local inventorycount = packet:ReadULong()

        if (itemid ~= ammoID) then
            return true
        end

        local newpacket = CreatePacket(358, (8+4+4+4+1+4+4+4+4+4))
        newpacket:WriteGUID(guid)
        newpacket:WriteULong(received)
        newpacket:WriteULong(created)
        newpacket:WriteULong(0)
        newpacket:WriteUByte(bagslot)
        newpacket:WriteULong(itemslot)
        newpacket:WriteULong(itemid)
        newpacket:WriteULong(suffixfactor)
        newpacket:WriteLong(randompropertyid)
        newpacket:WriteULong(count)
        newpacket:WriteULong(inventorycount)
        
        player:SetData("_skip_ammo_msg", nil)
        player:SendPacket(newpacket)
        return false
    end
    return true
end

local function moduleAnnounce(event, player)
    player:SendBroadcastMessage("This server is running the |cff4CFF00InfiniteAmmo|r module.")
end

RegisterPlayerEvent(5, onSpellCast) -- PLAYER_EVENT_ON_SPELL_CAST
RegisterPacketEvent(358, 7, onSendItemPushResult) -- PACKET_EVENT_ON_PACKET_SEND (SMSG_ITEM_PUSH_RESULT)
if (AnnounceModule==1 and EnableModule==1) then
    RegisterPlayerEvent(3, moduleAnnounce)   -- PLAYER_EVENT_ON_LOGIN
end

PrintInfo("["..FILE_NAME.."] InfiniteAmmo module loaded.")
