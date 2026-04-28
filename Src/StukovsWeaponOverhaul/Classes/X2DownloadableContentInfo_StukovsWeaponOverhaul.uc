// File: X2DownloadableContentInfo_StukovsWeaponOverhaul.uc
// Enhanced version with support for weapon-specific custom ranges

class X2DownloadableContentInfo_StukovsWeaponOverhaul extends X2DownloadableContentInfo config (StukovWeaponOverhaul);

// Category-based Range Tables (your existing ones)
var config array<int>SKV_PISTOL_RANGE;
var config array<int>SKV_SMG_RANGE;
var config array<int>SKV_RIFLE_RANGE;
var config array<int>SKV_SHOTGUN_RANGE;
var config array<int>SKV_LMG_RANGE;
var config array<int>SKV_SNIPER_RANGE;
var config array<int>SKV_SEMISNIPER_RANGE;
var config array<int>SKV_BULLPUP_RANGE;
var config array<int>SKV_CROSSBOW_RANGE;
var config array<int>SKV_BOLTCASTER_RANGE;
var config array<int>SKV_FLAT_RANGE;

var config array<int>SKV_ALIENS_PISTOL_RANGE;
var config array<int>SKV_ALIENS_SMG_RANGE;
var config array<int>SKV_ALIENS_RIFLE_RANGE;
var config array<int>SKV_ALIENS_SHOTGUN_RANGE;
var config array<int>SKV_ALIENS_LMG_RANGE;
var config array<int>SKV_ALIENS_SNIPER_RANGE;

var config array<string> SKV_WEAPONS_TO_MODIFY;

// NEW: Weapon-specific custom range configurations
struct WeaponCustomRange
{
    var string WeaponName;
    var array<int> CustomRanges;
};
var config array<WeaponCustomRange> SKV_WEAPON_CUSTOM_RANGES;

// NEW: Weapon-specific named range table assignments
struct WeaponRangeTableAssignment
{
    var string WeaponName;
    var string RangeTableName;  // e.g., "pistol", "smg", "rifle", etc.
};
var config array<WeaponRangeTableAssignment> SKV_WEAPON_RANGE_ASSIGNMENTS;

static function int ChangeWeaponTable( name nWeaponName, optional array<int> tTableArray) {
   local X2ItemTemplateManager			AllItems;
   local X2WeaponTemplate               CurrentWeapon;
   local array<int>                     FinalRangeTable;

   AllItems = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
   CurrentWeapon = X2WeaponTemplate(AllItems.FindItemTemplate(nWeaponName));

   // `log("Processing Weapon: " $ nWeaponName,,'SKV');
   
   if ( CurrentWeapon == none ) {
	  return -1;
   }

   if ( CurrentWeapon.IsA('X2WeaponTemplate') == false ) {
	  return -1;
	}

   // Priority 1: Check if a manual Table Array was provided
   if ( tTableArray.Length > 0 ) {
	  CurrentWeapon.RangeAccuracy = tTableArray;
	  // `log("Changing to Custom Specified Range (manual parameter).",,'SKV');
	  return 1;
   }
   
   // Priority 2: Check if this specific weapon has a custom range defined in config
   FinalRangeTable = GetCustomRangeForWeapon(string(nWeaponName));
   if ( FinalRangeTable.Length > 0 ) {
	  CurrentWeapon.RangeAccuracy = FinalRangeTable;
	  // `log("Changing to Custom Specified Range for weapon: " $ nWeaponName,,'SKV');
	  return 1;
   }
   
   // Priority 3: Check if this weapon has a specific range table assigned
   FinalRangeTable = GetAssignedRangeTable(string(nWeaponName));
   if ( FinalRangeTable.Length > 0 ) {
	  CurrentWeapon.RangeAccuracy = FinalRangeTable;
	  // `log("Changing to Assigned Range Table for weapon: " $ nWeaponName,,'SKV');
	  return 1;
   }
   
   // Priority 4: Use the default table for the weapon category
   switch ( CurrentWeapon.WeaponCat ) {
	 case 'Pistol':
		CurrentWeapon.RangeAccuracy = default.SKV_PISTOL_RANGE;
		// `log("Changing to Pistol Range.",,'SKV');
		break;
	 case 'Rifle':
		CurrentWeapon.RangeAccuracy = default.SKV_RIFLE_RANGE;
		// `log("Changing to Rifle Range.",,'SKV');
		break;
	 case 'Shotgun':
		CurrentWeapon.RangeAccuracy = default.SKV_SHOTGUN_RANGE;
		// `log("Changing to Shotgun Range.",,'SKV');
		break;
	 case 'Sniper_Rifle':
		CurrentWeapon.RangeAccuracy = default.SKV_SNIPER_RANGE;
		// `log("Changing to Sniper Range.",,'SKV');
		break;
	 case 'Cannon':
		CurrentWeapon.RangeAccuracy = default.SKV_LMG_RANGE;
		// `log("Changing to LMG Range.",,'SKV');
		break;
	 case 'SMG':
		CurrentWeapon.RangeAccuracy = default.SKV_SMG_RANGE;
		// `log("Changing to SMG Range.",,'SKV');
		break;
	case 'sidearm':
		CurrentWeapon.RangeAccuracy = default.SKV_SMG_RANGE;
		// `log("Changing to SMG Range.",,'SKV');
		break;
	 case 'Vektor_Rifle':
		CurrentWeapon.RangeAccuracy = default.SKV_SEMISNIPER_RANGE;
		// `log("Changing to Semisniper Range.",,'SKV');
		break;
	case 'StrikeRifle':
		CurrentWeapon.RangeAccuracy = default.SKV_SEMISNIPER_RANGE;
		// `log("Changing to Semisniper Range.",,'SKV');
		break;
	case 'Bullpup':
		CurrentWeapon.RangeAccuracy = default.SKV_BULLPUP_RANGE;
		// `log("Changing to Bullpup Range.",,'SKV');
		break;
	case 'BattleRifle':
		CurrentWeapon.RangeAccuracy = default.SKV_LMG_RANGE;
		// `log("Changing to LMG Range.",,'SKV');
		break;
	case 'BoltCaster':
		CurrentWeapon.RangeAccuracy = default.SKV_BOLTCASTER_RANGE;
		// `log("Changing to LMG Range.",,'SKV');
		break;
	case 'HunterRifle':
		CurrentWeapon.RangeAccuracy = default.SKV_RIFLE_RANGE;
		// `log("Changing to Rifle Range.",,'SKV');
		break;
	 default:
		// `log("Not a standard gun, skipping.",,'SKV');
		break;
   }   

   return 1;
}

// NEW: Helper function to get custom range for a specific weapon
static function array<int> GetCustomRangeForWeapon(string WeaponName)
{
    local WeaponCustomRange CustomRange;
    local array<int> EmptyArray;
    local int i;
    
    EmptyArray.Length = 0; // Explicitly initialize to avoid compiler warning
    
    // Search through all custom ranges defined in config
    for (i = 0; i < default.SKV_WEAPON_CUSTOM_RANGES.Length; i++)
    {
        CustomRange = default.SKV_WEAPON_CUSTOM_RANGES[i];
        if (CustomRange.WeaponName == WeaponName && CustomRange.CustomRanges.Length > 0)
        {
            // `log("Found custom range for weapon: " $ WeaponName $ " with " $ CustomRange.CustomRanges.Length $ " range values",,'SKV');
            return CustomRange.CustomRanges;
        }
    }
    
    // Return empty array if no custom range found
    return EmptyArray;
}

// NEW: Helper function to get assigned range table for a specific weapon
static function array<int> GetAssignedRangeTable(string WeaponName)
{
    local WeaponRangeTableAssignment Assignment;
    local array<int> EmptyArray;
    local int i;
    
    EmptyArray.Length = 0; // Explicitly initialize to avoid compiler warning
    
    // Search through all range table assignments
    for (i = 0; i < default.SKV_WEAPON_RANGE_ASSIGNMENTS.Length; i++)
    {
        Assignment = default.SKV_WEAPON_RANGE_ASSIGNMENTS[i];
        if (Assignment.WeaponName == WeaponName && Assignment.RangeTableName != "")
        {
            // `log("Found range table assignment for weapon: " $ WeaponName $ " -> " $ Assignment.RangeTableName,,'SKV');
            
            // Return the appropriate range table based on the config name
            return GetRangeTableByName(Assignment.RangeTableName);
        }
    }
    
    // Return empty array if no assignment found
    return EmptyArray;
}

// NEW: Helper function to get range table by its config name
static function array<int> GetRangeTableByName(string TableName)
{
    local array<int> EmptyArray;
    local string ProcessedName;
    
    EmptyArray.Length = 0; // Explicitly initialize to avoid compiler warning
    
    // Process the table name to handle different formats
    ProcessedName = ProcessRangeTableName(TableName);
    
    // Match against all available range tables using a single switch
    switch(ProcessedName)
    {
        case "PISTOL":
            return default.SKV_PISTOL_RANGE;
        case "SMG":
            return default.SKV_SMG_RANGE;
        case "RIFLE":
            return default.SKV_RIFLE_RANGE;
        case "SHOTGUN":
            return default.SKV_SHOTGUN_RANGE;
        case "LMG":
            return default.SKV_LMG_RANGE;
        case "SNIPER":
            return default.SKV_SNIPER_RANGE;
        case "SEMISNIPER":
            return default.SKV_SEMISNIPER_RANGE;
        case "BULLPUP":
            return default.SKV_BULLPUP_RANGE;
        case "CROSSBOW":
            return default.SKV_CROSSBOW_RANGE;
        case "BOLTCASTER":
            return default.SKV_BOLTCASTER_RANGE;
        case "FLAT":
            return default.SKV_FLAT_RANGE;
        case "ALIENS_PISTOL":
            return default.SKV_ALIENS_PISTOL_RANGE;
        case "ALIENS_SMG":
            return default.SKV_ALIENS_SMG_RANGE;
        case "ALIENS_RIFLE":
            return default.SKV_ALIENS_RIFLE_RANGE;
        case "ALIENS_SHOTGUN":
            return default.SKV_ALIENS_SHOTGUN_RANGE;
        case "ALIENS_LMG":
            return default.SKV_ALIENS_LMG_RANGE;
        case "ALIENS_SNIPER":
            return default.SKV_ALIENS_SNIPER_RANGE;
        default:
            // `log("Warning: Unknown range table name: " $ TableName $ " (processed as: " $ ProcessedName $ ")",,'SKV');
            return EmptyArray;
    }
}

// Helper to process range table names into a standard format
static function string ProcessRangeTableName(string TableName)
{
    local string ProcessedName;
    
    // Convert to uppercase
    ProcessedName = Caps(TableName);
    
    // Remove SKV_ prefix if present
    if (Left(ProcessedName, 4) == "SKV_")
    {
        ProcessedName = Mid(ProcessedName, 4);
    }
    
    // Remove _RANGE suffix if present
    if (Right(ProcessedName, 6) == "_RANGE")
    {
        ProcessedName = Left(ProcessedName, Len(ProcessedName) - 6);
    }
    
    return ProcessedName;
}

// Robojumper code from an internet post. Great stuff.
static function bool ModInstalled(name ModName)
{
	local XComOnlineEventMgr EventManager;
	local int i;

	EventManager = `ONLINEEVENTMGR;
	for(i = EventManager.GetNumDLC() - 1; i >= 0; i--)
	{
		if(EventManager.GetDLCNames(i) == ModName)
		{
			return true;
		}
	}
	return false;
}

// This function runs when templates are created, allowing us to modify them
static event OnPostTemplatesCreated()
{
    local X2AbilityTemplateManager AbilityTemplateManager;
    local X2AbilityTemplate AbilityTemplate;
	local int i;
    
    AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
    
    // Find the SoulReaper ability template
    AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('SoulReaper');
    
    if (AbilityTemplate != none)
    {
        // Add our weapon restriction condition to the existing ability
        AbilityTemplate.AbilityShooterConditions.AddItem(new class'X2Condition_WeaponRestriction_Simple');
        
        // `log("StukovsWeaponOverhaul: Added weapon restriction to SoulReaper ability");
    }
    else
    {
        // `log("StukovsWeaponOverhaul: Could not find SoulReaper ability template");
    }

    // Process all weapons in the modification list
    for (i = 0; i < default.SKV_WEAPONS_TO_MODIFY.Length; i++)
    {
        // Pass empty array to use automatic detection (custom ranges first, then category)
        ChangeWeaponTable(name(default.SKV_WEAPONS_TO_MODIFY[i]));
    }
}