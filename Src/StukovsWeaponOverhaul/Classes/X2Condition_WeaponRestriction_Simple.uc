// File: X2Condition_WeaponRestriction_Simple.uc  
// This goes in YourModName/Src/YourModName/Classes/

class X2Condition_WeaponRestriction_Simple extends X2Condition;

// List of forbidden weapon template names
var array<name> ForbiddenWeaponNames;

// Constructor - set up the forbidden weapons here
function InitForbiddenWeapons()
{
    // Add the weapons you want to restrict
    ForbiddenWeaponNames.AddItem('VektorRifle_LS');
	ForbiddenWeaponNames.AddItem('AssaultRifle_LS');
	ForbiddenWeaponNames.AddItem('SMG_LS');
	ForbiddenWeaponNames.AddItem('Cannon_LS');
	ForbiddenWeaponNames.AddItem('Shotgun_LS');
	ForbiddenWeaponNames.AddItem('SniperRifle_LS');
	ForbiddenWeaponNames.AddItem('Pistol_LS');
	ForbiddenWeaponNames.AddItem('Carbine_LS_Ghost');
	ForbiddenWeaponNames.AddItem('StrikeRifle_LS_Ghost');
	ForbiddenWeaponNames.AddItem('BattleRifle_LS_Ghost');
	ForbiddenWeaponNames.AddItem('AssaultRifle_LS_Ghost');
	ForbiddenWeaponNames.AddItem('Shotgun_LS_Ghost');
	ForbiddenWeaponNames.AddItem('SniperRifle_LS_Ghost');
	ForbiddenWeaponNames.AddItem('Cannon_LS_Ghost');
	ForbiddenWeaponNames.AddItem('Pistol_LS_Ghost');
	ForbiddenWeaponNames.AddItem('Sidearm_LS');
	ForbiddenWeaponNames.AddItem('Bullpup_LS');
	ForbiddenWeaponNames.AddItem('SparkRifle_LS');
	ForbiddenWeaponNames.AddItem('IRI_ArtilleryCannon_LS');
	ForbiddenWeaponNames.AddItem('SawedOffShotgun_LS');
	ForbiddenWeaponNames.AddItem('ABBA_LMG_LASER');
	ForbiddenWeaponNames.AddItem('ABBA_LMG_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_SHOTGUN_LASER');
	ForbiddenWeaponNames.AddItem('ABBA_SHOTGUN_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_SNIPERRIFLE_LASER');
	ForbiddenWeaponNames.AddItem('ABBA_SNIPERRIFLE_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_ASSAULTRIFLE_LASER');
	ForbiddenWeaponNames.AddItem('ABBA_ASSAULTRIFLE_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_PISTOL_LASER');
	ForbiddenWeaponNames.AddItem('ABBA_PISTOL_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_SMG_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_SPARKRIFLE_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_BULLPUP_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_VEKTORRIFLE_LASERM2');
	ForbiddenWeaponNames.AddItem('ABBA_AUTOPISTOL_LASERM2');
	ForbiddenWeaponNames.AddItem('BRSR_BATTLERIFLE_Laser');
	ForbiddenWeaponNames.AddItem('HunterRifle_Laser');

    // Add more weapons here if needed:
    // ForbiddenWeaponNames.AddItem('AssaultRifle_MG');
}

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit UnitState;
    local XComGameState_Item WeaponState;
    local X2WeaponTemplate WeaponTemplate;
    local name WeaponName;
    local int i;
    
    // Initialize forbidden weapons if not done yet
    if (ForbiddenWeaponNames.Length == 0)
    {
        InitForbiddenWeapons();
    }
    
    UnitState = XComGameState_Unit(kTarget);
    if (UnitState == none)
        return 'AA_NotAUnit';
    
    // Get the unit's primary weapon
    WeaponState = UnitState.GetPrimaryWeapon();
    if (WeaponState == none)
        return 'AA_Success'; // No weapon equipped, allow ability
    
    WeaponTemplate = X2WeaponTemplate(WeaponState.GetMyTemplate());
    if (WeaponTemplate == none)
        return 'AA_Success';
    
    WeaponName = WeaponTemplate.DataName;
    
    // Check if current weapon is in the forbidden list
    for (i = 0; i < ForbiddenWeaponNames.Length; i++)
    {
        if (WeaponName == ForbiddenWeaponNames[i])
        {
            return 'AA_WeaponIncompatible';
        }
    }
    
    return 'AA_Success';
}

// Optional: Provide a custom error message
function string GetConditionFriendlyName(optional bool bPositiveDisplay = false)
{
    if (bPositiveDisplay)
        return "Compatible Weapon Required";
    else
        return "Cannot use with current weapon";
}