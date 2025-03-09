module TriggerModeControl
import TriggerModeControl.Config.*

///////////////////////////////////////////////////////////////////////////////////////////////
// EquipmentBaseTransition, UnequipCycleEvents

// helper method
@addMethod(EquipmentBaseTransition)
private final func GetWeaponTriggerModesNumber(scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
  let weaponObject: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  if !weaponObject.HasSecondaryTriggerMode() {
   return 1;
  };
  let triggerModesArray: array<wref<TriggerMode_Record>>;
  weaponObject.GetWeaponRecord().TriggerModes(triggerModesArray);
  return ArraySize(triggerModesArray);
}

// check if weapon is tagged and handle partecipation
@wrapMethod(EquipmentBaseTransition)
protected final const func HandleWeaponEquip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
  wrappedMethod(scriptInterface, stateContext, stateMachineInstanceData, item);
  let weaponObject: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  let isTech: Bool = Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).Evolution().Type(), gamedataWeaponEvolution.Tech);
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  if weaponObject.WeaponHasTag(n"ManualTriggerSwap") {
    stateContext.SetPermanentBoolParameter(n"isTriggerModeCtrlApplied", true, true);
  };
  if !stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) && this.GetWeaponTriggerModesNumber(scriptInterface) > 1 && ((settings.overrideOthers && !isTech) || (settings.overrideTech && isTech)) {
    stateContext.SetPermanentBoolParameter(n"isTriggerModeCtrlApplied", true, true);
    stateContext.SetPermanentBoolParameter(n"isTriggerModeCtrlOverride", true, true);
  };
  stateContext.SetPermanentBoolParameter(n"isSecondaryAttackMode", false, true);
}

@wrapMethod(UnequipCycleEvents)
protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let item: ItemID = this.GetItemIDFromParam(this.stateMachineInstanceData, stateContext);
  if this.IsRightHandLogic(this.stateMachineInstanceData) && Equals(this.GetItemCategoryFromItemID(item), gamedataItemCategory.Weapon) {
    stateContext.RemovePermanentBoolParameter(n"isTriggerModeCtrlApplied");
    stateContext.RemovePermanentBoolParameter(n"isTriggerModeCtrlOverride");
    stateContext.RemovePermanentBoolParameter(n"isSecondaryAttackMode");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
  };
  wrappedMethod(stateContext, scriptInterface);
}


///////////////////////////////////////////////////////////////////////////////////////////////
// InputContextTransitionEvents

@addMethod(InputContextTransitionEvents)
private final const func AddTriggerModeCtrlInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, group: CName) -> Void {
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    let weaponObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    let weaponRecord: wref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
    let settings: wref<TMCSettings> = TMCSettings.GetSettings();
    if Equals(weaponRecord.PrimaryTriggerMode(), weaponRecord.SecondaryTriggerMode()) {
      if weaponObject.WeaponHasTag(n"AimingBoundAttacks") {
        return;
      };
      if !stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Primary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
        return;
      };
      if stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Secondary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
        return;
      };
    };
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.FullAuto) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      return;
    };
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Charge"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      return;
    };
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Burst) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Burst"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      return;
    };
    if (settings.overrideAuto || weaponObject.WeaponHasTag(n"ForceAutoPrimary")) && !stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
      if Equals(weaponRecord.SecondaryTriggerMode().Type(), gamedataTriggerMode.FullAuto) {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Primary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      } else {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      };
      return;
    };
    if (settings.overrideAuto || weaponObject.WeaponHasTag(n"ForceAutoSecondary")) && stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
      if Equals(weaponRecord.PrimaryTriggerMode().Type(), gamedataTriggerMode.FullAuto) {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Secondary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      } else {
        this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      };
      return;
    };
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.SemiAuto) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-SemiAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
      return;
    };
  };
}


// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"Ranged");
}

// Vehicle Combat: add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"VehicleDriverCombat");
}

// Vehicle Combat: add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatTPPInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface, n"VehicleDriverCombatTPP");
}


///////////////////////////////////////////////////////////////////////////////////////////////
// CycleTriggerModeDecisions and CycleTriggerModeEvents, ReadyEvents

// change cycle enter condition from ADS to button press
@replaceMethod(CycleTriggerModeDecisions)  
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    return scriptInterface.IsActionJustPressed(n"TriggerSwap");
  };
  if stateContext.IsStateActive(n"UpperBody", n"aimingState") && this.IsPrimaryTriggerModeActive(scriptInterface) {
    return true;
  };
  if !stateContext.IsStateActive(n"UpperBody", n"aimingState") && !this.IsPrimaryTriggerModeActive(scriptInterface) {
    return true;
  };
  return false;
}

@replaceMethod(CycleTriggerModeDecisions)
protected final func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let weaponObject: ref<WeaponObject> = scriptInterface.owner as WeaponObject;
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    this.EnableOnEnterCondition(IsDefined(weaponObject.GetWeaponRecord().SecondaryTriggerMode()));
    return;
  };
  this.EnableOnEnterCondition(weaponObject.HasSecondaryTriggerMode());
}

@wrapMethod(CycleTriggerModeEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  if IsDefined(weaponObject.GetWeaponRecord().SecondaryTriggerMode()) {
    if stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
      stateContext.SetPermanentBoolParameter(n"isSecondaryAttackMode", false, true);
      StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
    } else {
      stateContext.SetPermanentBoolParameter(n"isSecondaryAttackMode", true, true);
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger");
    };
  };
  if weaponObject.HasSecondaryTriggerMode() || stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    this.SwitchTriggerMode(stateContext, scriptInterface);
    PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);               // refresh button hints
    GameObject.PlaySoundEvent(scriptInterface.executionOwner, n"w_gun_pistol_power_unity_trigger");                                // play sound
  };
  if weaponObject.WeaponHasTag(n"ResetChargeOnSwap") {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    if statPoolsSystem.HasActiveStatPool(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge) {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, 0.0, scriptInterface.executionOwner);
    };
  };
}

// refresh button hints
@wrapMethod(ReadyEvents)
protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);                   // refresh button hints
}


///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponTransition

// grab correct stats
@replaceMethod(WeaponTransition)
protected final const func IsPrimaryTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let weaponRecord: ref<WeaponItem_Record> = weapon.GetWeaponRecord();
  if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  return false;
}

@replaceMethod(WeaponTransition)
  protected final func SetupStandardShootingSequence(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let burstCycleTimeStat: gamedataStatType = gamedataStatType.CycleTime_Burst;
    let burstNumShots: gamedataStatType = gamedataStatType.NumShotsInBurst;
    if this.GetWeaponTriggerModesNumber(scriptInterface) > 1 && !this.IsPrimaryTriggerModeActive(scriptInterface) {
      burstCycleTimeStat = gamedataStatType.CycleTime_BurstSecondary;
      burstNumShots = gamedataStatType.NumShotsInBurstSecondary;
    };
    this.StartShootingSequence(stateContext, scriptInterface, statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.PreFireTime), statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), burstCycleTimeStat), Cast<Int32>(statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), burstNumShots)), false);
  }

// select correct attack
@replaceMethod(WeaponTransition)
protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
  let attackRecord: ref<Attack_Record>;
  let isSecondary: Bool = stateContext.IsStateActive(n"UpperBody", n"aimingState");
  let magazine: InnerItemData;
  let rangedAttack: ref<RangedAttack_Record>;
  let weaponCharge: Float;
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let weaponRecord: ref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
  this.m_rangedAttackPackage = weaponObject.GetCurrentRangedAttack();

  weaponObject.GetItemData().GetItemPart(magazine, t"AttachmentSlots.DamageMod");
  if this.m_magazineID != ItemID.GetTDBID(InnerItemData.GetItemID(magazine)) {
    this.m_magazineID = ItemID.GetTDBID(InnerItemData.GetItemID(magazine));
    if TDBID.IsValid(this.m_magazineID) {
      this.m_magazineAttack = TDBID.Create(TweakDBInterface.GetString(this.m_magazineID + t".overrideAttack", ""));
      this.m_rangedAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord(this.m_magazineAttack);
    } else {
      this.m_magazineAttack = t"NewPerks.Intelligence_Left_Milestone_2.preventInQueueAgain";
    };
  };
  
  if !weaponObject.WeaponHasTag(n"AimingBoundAttacks") && stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) && !stateContext.GetBoolParameter(n"isTriggerModeCtrlOverride", true) {
      isSecondary = stateContext.GetBoolParameter(n"isSecondaryAttackMode", true);
    };
  weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
  rangedAttack = weaponCharge >= 1.00 ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
  
  if scriptInterface.GetTimeSystem().IsTimeDilationActive() {
    if isSecondary {
      attackRecord = rangedAttack.SecondaryPlayerTimeDilated();
    };
    if !IsDefined(attackRecord) {
      attackRecord = rangedAttack.PlayerTimeDilated();
    };
  };
  if !IsDefined(attackRecord) {
    if isSecondary {
      attackRecord = rangedAttack.SecondaryPlayerAttack();
    };
  };
  if !IsDefined(attackRecord) {
    attackRecord = rangedAttack.PlayerAttack();
  };

  return attackRecord;
}

// ForceAuto
@wrapMethod(WeaponTransition)
protected final const func CanHoldToShoot(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weaponObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  if weaponObject.WeaponHasTag(n"ForceAutoPrimary") && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  if weaponObject.WeaponHasTag(n"ForceAutoSecondary") && StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  let result: Bool = wrappedMethod(scriptInterface);
  if settings.overrideAuto {
    result = true;
  };
  if result && settings.overrideHoldCharge {
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge) && scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID()), gamedataStatType.CanControlFullyChargedWeapon) > 0.0 {
      result = false;
    };
  };
  return result;
}

// RemoveAuto
@wrapMethod(WeaponTransition)
protected final const func IsFullAutoAction(weaponObject: ref<WeaponObject>, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let result: Bool = wrappedMethod(weaponObject, stateContext, scriptInterface);
  if (weaponObject.WeaponHasTag(n"RemoveAutoPrimary") && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger"))
  || (weaponObject.WeaponHasTag(n"RemoveAutoSecondary") && StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger")) {
    return scriptInterface.IsActionJustPressed(n"RangedAttack");
  };
  return result;
}

// NoAutomaticReload
@wrapMethod(NoAmmoDecisions)
protected final const func ToReload(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let result: Bool = wrappedMethod(stateContext, scriptInterface);
  if this.GetWeaponObject(scriptInterface).WeaponHasTag(n"NoAutomaticReload") {
    if !scriptInterface.IsActionJustPressed(n"RangedAttack") && !scriptInterface.IsActionJustPressed(n"Reload") {
      return false;
    };
  };
  return result;
}

// PartialChargeFire
@replaceMethod(ChargeDecisions)
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let lastShotTime: Float;
  let actionPressCount: Uint32 = scriptInterface.GetActionPressCount(n"RangedAttack");
  let lastChargePressCount: StateResultInt = stateContext.GetPermanentIntParameter(n"LastChargePressCount");
  if lastChargePressCount.valid && lastChargePressCount.value == Cast<Int32>(actionPressCount) {
    if !this.CanHoldToShoot(scriptInterface) {
      this.EnableOnEnterCondition(false);
      return false;
    };
    lastShotTime = stateContext.GetFloatParameter(n"LastShotTime", true);
    if EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) < lastShotTime + 0.00 {
      return false;
    };
  };
  let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  let uncharged: Bool = scriptInterface.GetStatPoolsSystem().GetStatPoolValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatPoolType.WeaponCharge) <= this.GetWeaponChargeMinValue(scriptInterface) || weapon.WeaponHasTag(n"PartialChargeFire");
  return !weapon.IsMagazineEmpty() && uncharged;
}

// ForceInstantDischarge & GradualChargeDecay
@replaceMethod(ShootEvents)
protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
  let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  if Equals(statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.FullAutoOnFullCharge), 0.00) {
    if !weaponObject.WeaponHasTag(n"GradualChargeDecay") {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.GetWeaponChargeMinValue(scriptInterface), scriptInterface.executionOwner);
    };
  } else {
    if (weaponObject.WeaponHasTag(n"ForceInstantDischargePrimary") && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger"))
    || (weaponObject.WeaponHasTag(n"ForceInstantDischargeSecondary") && StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger")) {
      statPoolsSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, this.GetWeaponChargeMinValue(scriptInterface), scriptInterface.executionOwner);
    };
  };
}

//UnslowableCharge
@wrapMethod(ChargeEvents)
protected final func GetChargeValuePerSec(scriptInterface: ref<StateGameScriptInterface>) -> Float {
  let chargeTime: Float = wrappedMethod(scriptInterface);
  if chargeTime > 0.0 {
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    if timeSystem.IsTimeDilationActive(n"sandevistan") {
      let settings: wref<TMCSettings> = TMCSettings.GetSettings();
      let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
      if settings.overrideChargeSpeed
      || (weaponObject.WeaponHasTag(n"UnslowableChargePrimary") && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger"))
      || (weaponObject.WeaponHasTag(n"UnslowableChargeSecondary") && StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger")) {
        chargeTime /= timeSystem.GetActiveTimeDilation(n"sandevistan");
      };
    };
  };
  return chargeTime;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Extra

// ProtectedAttackPackage
@replaceMethod(OverrideRangedAttackPackageEffector)
protected func ActionOn(owner: ref<GameObject>) -> Void {
  let targetObject: wref<GameObject>;
  let targetWeapon: ref<WeaponObject>;
  if !this.GetApplicationTarget(owner, n"Weapon", targetObject) {
    return;
  };
  targetWeapon = targetObject as WeaponObject;
  if IsDefined(targetWeapon) && !targetWeapon.WeaponHasTag(n"ProtectedAttackPackage") {
    targetWeapon.OverrideRangedAttackPackage(this.m_attackPackage);
  };
}

@replaceMethod(OverrideRangedAttackPackageEffector)
protected func ActionOff(owner: ref<GameObject>) -> Void {
  let targetObject: wref<GameObject>;
  let targetWeapon: ref<WeaponObject>;
  if !this.GetApplicationTarget(owner, n"Weapon", targetObject) {
    return;
  };
  targetWeapon = targetObject as WeaponObject;
  if IsDefined(targetWeapon) && !targetWeapon.WeaponHasTag(n"ProtectedAttackPackage") {
    targetWeapon.DefaultRangedAttackPackage();
  };
}

// Internal Clock Rework compatibility
@wrapMethod(PerfectDischargePrereq)
protected final const func IsDischargePerfect(game: GameInstance, weaponObject: ref<WeaponObject>, opt state: ref<PerfectDischargePrereqState>) -> Bool {
  let result: Bool = wrappedMethod(game, weaponObject, state);
  if result {
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(player) {
      if (weaponObject.WeaponHasTag(n"ForceAutoPrimary") && !StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.PlayerSecondaryTrigger"))
      || (weaponObject.WeaponHasTag(n"ForceAutoSecondary") && StatusEffectSystem.ObjectHasStatusEffect(player, t"BaseStatusEffect.PlayerSecondaryTrigger")) {
        return false;
      };
    };
  };
  return result;
}

