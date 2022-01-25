-- 
DELETE FROM item_template WHERE entry=38059;
INSERT INTO item_template (entry, class, subclass, SoundOverrideSubclass, name, displayid, Quality, Flags, FlagsExtra, BuyCount, BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel, maxcount, stackable, ContainerSlots, delay, bonding, description, Material, RequiredDisenchantSkill, duration, ScriptName) VALUES 
(38059, 1, 0, -1, 'Enchanted Bag of Infinite Ammunition', 50457, 6, 0, 0, 1, 5000000, 0, 18, 13, -1, 80, 0, 1, 1, 36, 0, 1, '|cff00FF00Equip: Wear this bag and you will never run out of ammo again|r', 8, -1, 0, '');
