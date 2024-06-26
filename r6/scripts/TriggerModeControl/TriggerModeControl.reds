///////////////////////////////////////////////////////////////////////////////////////////////
// Mod Settings

@addField(PlayerPuppet) 
let manualTriggerSwap: ref<ManualTriggerSwap>;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  this.manualTriggerSwap = ManualTriggerSwap.Create();
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  this.manualTriggerSwap = null;
  wrappedMethod();
}


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
  if weaponObject.WeaponHasTag(n"ManualTriggerSwap") {
    stateContext.SetPermanentBoolParameter(n"isTriggerModeCtrlApplied", true, true);
  };
  if !stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) && this.GetWeaponTriggerModesNumber(scriptInterface) > 1 && (((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideOthers && !isTech) || ((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideTech && isTech)) {
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
    if ((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideAuto || weaponObject.WeaponHasTag(n"ForceAutoPrimary")) && !stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
	  if Equals(weaponRecord.SecondaryTriggerMode().Type(), gamedataTriggerMode.FullAuto) {
	    this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Primary"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
	  } else {
	    this.ShowInputHint(scriptInterface, n"TriggerSwap", group, GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
	  };
      return;
    };
    if ((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideAuto || weaponObject.WeaponHasTag(n"ForceAutoSecondary")) && stateContext.GetBoolParameter(n"isSecondaryAttackMode", true) {
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

// refresh button hints
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

// force automatic fire
@wrapMethod(WeaponTransition)
protected final const func CanHoldToShoot(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
  let weaponObject: wref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  if weaponObject.WeaponHasTag(n"ForceAutoPrimary") && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  if weaponObject.WeaponHasTag(n"ForceAutoSecondary") && StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerSecondaryTrigger") {
    return true;
  };
  let result: Bool = wrappedMethod(scriptInterface);
  if (scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideAuto {
    result = true;
  };
  if result && (scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideHoldCharge {
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge) && scriptInterface.GetStatsSystem().GetStatValue(Cast<StatsObjectID>(scriptInterface.executionOwner.GetEntityID()), gamedataStatType.CanControlFullyChargedWeapon) > 0.0 {
      result = false;
    };
  };
  return result;
}

