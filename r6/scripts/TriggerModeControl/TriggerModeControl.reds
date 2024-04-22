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
  wrappedMethod();
  this.manualTriggerSwap = null;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// EquipmentBaseTransition

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
  let isTech: Bool = Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).Evolution().Type(), gamedataWeaponEvolution.Tech);
  if this.GetWeaponTriggerModesNumber(scriptInterface) > 1 {
    if (((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideOthers && !isTech) || 
		((scriptInterface.executionOwner as PlayerPuppet).manualTriggerSwap.overrideTech && isTech) || 
		(scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject).WeaponHasTag(n"ManualTriggerSwap")) {
      stateContext.SetPermanentBoolParameter(n"isTriggerModeCtrlApplied", true, true);
    };
  };
}

@wrapMethod(EquipmentBaseTransition)
protected final const func HandleWeaponUnequip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
  stateContext.RemovePermanentBoolParameter(n"isTriggerModeCtrlApplied");
  wrappedMethod(scriptInterface, stateContext, stateMachineInstanceData, item);
}


///////////////////////////////////////////////////////////////////////////////////////////////
// InputContextTransitionEvents

// helper method
@addMethod(InputContextTransitionEvents)
private final func IsTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>, triggerMode: gamedataTriggerMode) -> Bool {
  let item: ref<ItemObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight");
  let weapon: ref<WeaponObject> = item as WeaponObject;

  if Equals(weapon.GetCurrentTriggerMode().Type(), triggerMode) {
    return true;
  };
  return false;
}

@addMethod(InputContextTransitionEvents)
private final const func AddTriggerModeCtrlInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    // SemiAuto
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.SemiAuto) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", n"Ranged", GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-SemiAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    };
    // Burst
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.Burst) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", n"Ranged", GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Burst"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    };
    // FullAuto
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.FullAuto) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", n"Ranged", GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-FullAuto"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    };
    // Charge
    if this.IsTriggerModeActive(scriptInterface, gamedataTriggerMode.Charge) {
      this.ShowInputHint(scriptInterface, n"TriggerSwap", n"Ranged", GetLocalizedTextByKey(n"Mod-TriggerModeCtrl-Charge"), inkInputHintHoldIndicationType.FromInputConfig, true, 1);
    };
  };
}

// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowRangedInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface);
}

// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface);
}

// add input hints
@wrapMethod(InputContextTransitionEvents)
protected final const func ShowVehicleDriverCombatTPPInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  this.AddTriggerModeCtrlInputHints(stateContext, scriptInterface);
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

// refresh button hints
@wrapMethod(CycleTriggerModeEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    // refresh button hints
    PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);
    // play sound
    GameObject.PlaySoundEvent(scriptInterface.executionOwner, n"w_gun_pistol_power_unity_trigger");
  };
}

// refresh button hints
@wrapMethod(ReadyEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);
  let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
  // refresh button hints
  PlayerGameplayRestrictions.PushForceRefreshInputHintsEventToPSM(scriptInterface.executionOwner as PlayerPuppet);
  // set weapon trigger mode if is different from last time
  if weaponObject.HasSecondaryTriggerMode() && !Equals(weaponObject.GetCurrentTriggerMode().Type(), weaponObject.m_triggerMode) {
    this.SwitchTriggerMode(stateContext, scriptInterface);
  };
}


///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponTransition

// TriggerBoundAttacks
@replaceMethod(WeaponTransition)
protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
  let attackRecord: ref<Attack_Record>;
  let isAiming: Bool = stateContext.IsStateActive(n"UpperBody", n"aimingState");
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

  weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
  rangedAttack = weaponCharge >= 1.00 ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
	
  if stateContext.GetBoolParameter(n"isTriggerModeCtrlApplied", true) {
    if Equals(weaponObject.GetCurrentTriggerMode().Type(), weaponRecord.SecondaryTriggerMode().Type()) {
      if scriptInterface.GetTimeSystem().IsTimeDilationActive() {
        attackRecord = rangedAttack.SecondaryPlayerTimeDilated();
      };
      if !IsDefined(attackRecord) {
        attackRecord = rangedAttack.SecondaryPlayerAttack();
      };
    }
    else {
      if scriptInterface.GetTimeSystem().IsTimeDilationActive() {
        attackRecord = rangedAttack.PlayerTimeDilated();
      };
    };
  }
  else {
    if scriptInterface.GetTimeSystem().IsTimeDilationActive() && !Equals(weaponRecord.Evolution().Type(), gamedataWeaponEvolution.Tech) {
      if isAiming {
        attackRecord = rangedAttack.SecondaryPlayerTimeDilated();
      };
      if !IsDefined(attackRecord) {
        attackRecord = rangedAttack.PlayerTimeDilated();
      };
    } else {
      if isAiming {
        attackRecord = rangedAttack.SecondaryPlayerAttack();
      };
    };
  };
  if !IsDefined(attackRecord) {
    attackRecord = rangedAttack.PlayerAttack();
  };

  return attackRecord;
}

// Preem Weaponsmith workaround
@wrapMethod(WeaponTransition)
protected final const func SwitchTriggerMode(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(stateContext, scriptInterface);  
  if this.GetWeaponTriggerModesNumber(scriptInterface) > 1 {
    let evt: ref<WeaponChangeTriggerModeEvent> = new WeaponChangeTriggerModeEvent();
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    let weaponRecord: ref<WeaponItem_Record> = weapon.GetWeaponRecord();
    if this.IsPrimaryTriggerModeActive(scriptInterface) {
      evt.triggerMode = weaponRecord.SecondaryTriggerMode().Type();
    } else {
      evt.triggerMode = weaponRecord.PrimaryTriggerMode().Type();
    };
    weapon.QueueEvent(evt);
  };
}

///////////////////////////////////////////////////////////////////////////////////////////////
// WeaponObject

@addField(WeaponObject)
let m_triggerMode : gamedataTriggerMode;
@addField(WeaponObject)
let m_triggerModeSet : Bool;

@addMethod(WeaponObject)
protected cb func OnWeaponChangeTriggerMode(evt: ref<WeaponChangeTriggerModeEvent>) -> Void {
  this.m_triggerMode = evt.triggerMode;
}

@wrapMethod(WeaponObject)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  if !this.m_triggerModeSet {
    this.m_triggerMode = this.m_weaponRecord.PrimaryTriggerMode().Type();
    this.m_triggerModeSet = true;
  };
}
