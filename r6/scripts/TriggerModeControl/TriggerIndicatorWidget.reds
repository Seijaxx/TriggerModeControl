module TriggerModeControl.Widget
import TriggerModeControl.*
import TriggerModeControl.Config.*

@if(ModuleExists("LimitedHudCommon"))
import LimitedHudCommon.*
@if(ModuleExists("LimitedHudCommon"))
import LimitedHudConfig.WeaponRosterModuleConfig


@addField(WeaponRosterGameController)
let activeTrigger: ref<inkText>;

@addField(WeaponRosterGameController)
let doubledTrigger: Bool;

@addField(WeaponRosterGameController)
let labelOverride: Bool;

@addField(WeaponRosterGameController)
let projE3HUD: Bool;

// create and reparent widget
@wrapMethod(WeaponRosterGameController)
protected cb func OnInitialize() -> Bool {
  this.activeTrigger = new inkText();
  this.activeTrigger.SetName(n"trigger_indicator");
  this.activeTrigger.SetFitToContent(true);
  this.activeTrigger.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  this.activeTrigger.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.activeTrigger.SetAnchor(inkEAnchor.TopLeft);
  this.activeTrigger.SetHAlign(inkEHorizontalAlign.Left);
  this.activeTrigger.SetContentHAlign(inkEHorizontalAlign.Left);
  this.activeTrigger.SetHorizontalAlignment(textHorizontalAlignment.Left);
  this.activeTrigger.SetVAlign(inkEVerticalAlign.Top);
  this.activeTrigger.SetContentVAlign(inkEVerticalAlign.Top);
  this.activeTrigger.SetVerticalAlignment(textVerticalAlignment.Top);
  this.activeTrigger.SetLetterCase(textLetterCase.UpperCase);
  this.activeTrigger.SetVisible(true);
  this.activeTrigger.SetOpacity(0.0);
  let parent: ref<inkCompoundWidget> = (this.GetRootCompoundWidget().GetWidget(n"weapon_on_foot/ammo_counter/weapon_wrapper/new_ammo_wrapper/selective_fire") as inkCompoundWidget);          // Project E3 - HUD
  if IsDefined(parent) {
    parent.RemoveAllChildren();
    this.activeTrigger.BindProperty(n"tintColor", n"MainColors.Red");
    this.activeTrigger.SetMargin(95.0, -10.0, 0.0, 0.0);
    this.activeTrigger.SetFontStyle(n"Bold");
    this.activeTrigger.SetFontSize(41);
    this.projE3HUD = true;
  } else {
    parent = (this.GetRootCompoundWidget().GetWidget(n"weapon_on_foot/ammo_counter") as inkCompoundWidget);
    this.activeTrigger.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    this.activeTrigger.SetMargin(13.0, -30.0, 0.0, 0.0);
    this.activeTrigger.SetFontStyle(n"Medium");
    this.activeTrigger.SetFontSize(32);
    this.projE3HUD = false;
  };
  this.activeTrigger.Reparent(parent);
  return wrappedMethod();
}

@wrapMethod(WeaponRosterGameController)
protected cb func OnUninitialize() -> Bool {
  this.activeTrigger = null;
  return wrappedMethod();
}

// select and apply current label
@addMethod(WeaponRosterGameController)
private final func GetTriggerModeKey(secondaryTrigger: Bool) -> CName {
  let triggerStr: String;
  let triggerType: gamedataTriggerMode;
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  if secondaryTrigger {
    triggerType = this.m_weaponRecord.SecondaryTriggerMode().Type();
    triggerStr = "Secondary";
  } else {
    triggerType = this.m_weaponRecord.PrimaryTriggerMode().Type();
    triggerStr = "Primary";
  };
  if settings.overrideAuto || this.m_weaponRecord.TagsContains(n"ForceAuto") || this.m_weaponRecord.TagsContains(StringToName("ForceAuto" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-FullAuto";
  };
  if this.m_weaponRecord.TagsContains(n"RemoveAuto") || this.m_weaponRecord.TagsContains(StringToName("RemoveAuto" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-SemiAuto";
  };
  if this.m_weaponRecord.TagsContains(n"InstantCharge") || this.m_weaponRecord.TagsContains(StringToName("InstantCharge" + triggerStr)) {
    return n"Mod-TriggerModeCtrl-SemiAuto";
  };
  switch triggerType {
    case gamedataTriggerMode.FullAuto: return n"Mod-TriggerModeCtrl-FullAuto";
    case gamedataTriggerMode.Charge: return n"Mod-TriggerModeCtrl-Charge";
    case gamedataTriggerMode.Burst: return n"Mod-TriggerModeCtrl-Burst";
  };
  return n"Mod-TriggerModeCtrl-SemiAuto";
}

@addMethod(WeaponRosterGameController)
private final func GetCurrentTriggerModeKey() -> CName {
  let secondaryTrigger: Bool = StatusEffectSystem.ObjectHasStatusEffect(this.m_player, t"BaseStatusEffect.PlayerSecondaryTrigger");
  let primaryKey: CName = this.GetTriggerModeKey(false);
  let secondaryKey: CName = this.GetTriggerModeKey(true);
  this.doubledTrigger = Equals(primaryKey, secondaryKey);
  if this.doubledTrigger || this.m_weaponRecord.TagsContains(n"SimpleTriggerLabels") {
    return secondaryTrigger ? n"Mod-TriggerModeCtrl-Secondary" : n"Mod-TriggerModeCtrl-Primary";
  };
  return secondaryTrigger ? secondaryKey : primaryKey;
}

@wrapMethod(WeaponRosterGameController)
protected cb func OnWeaponDataChanged(value: Variant) -> Bool {
  let result: Bool = wrappedMethod(value);
  this.activeTrigger.SetText(GetLocalizedTextByKey(this.GetCurrentTriggerModeKey()));
  return result;
}

// show/hide updates
@wrapMethod(WeaponRosterGameController)
private final func SetRosterSlotData() -> Void {
  wrappedMethod();
  let settings: wref<TMCSettings> = TMCSettings.GetSettings();
  this.labelOverride = settings.overrideWidget;
}

@if(!ModuleExists("LimitedHudCommon"))
@addMethod(WeaponRosterGameController)
protected final func IsWidgetVisible() -> Bool {
  return IsDefined(this.m_player) && this.m_isUnholstered;
}

@if(ModuleExists("LimitedHudCommon"))
@addMethod(WeaponRosterGameController)
protected final func IsWidgetVisible() -> Bool {
  return this.lhudConfig.IsEnabled ? this.lhud_isVisibleNow : this.lhud_isWeaponUnsheathed;
}

@addMethod(WeaponRosterGameController)
protected final func SetTriggerIndicatorVisibility() -> Void {
  let primaryTrigger: wref<TriggerMode_Record> = this.m_weaponRecord.PrimaryTriggerMode();
  if !IsDefined(primaryTrigger) || this.m_inWeaponizedVehicle {
    this.activeTrigger.SetOpacity(0.0);
    return;
  };
  if this.projE3HUD || this.labelOverride {
    this.activeTrigger.SetOpacity(this.IsWidgetVisible() ? 1.0 : 0.0);
    return;
  };
  if this.doubledTrigger && this.m_weaponRecord.TagsContains(n"AimingBoundAttacks"){
    this.activeTrigger.SetOpacity(0.0);
    return;
  };
  if this.m_weaponRecord.CanManuallySwapTriggers() && this.IsWidgetVisible() {
    this.activeTrigger.SetOpacity(1.0);
    return;
  };
  this.activeTrigger.SetOpacity(0.0);
}

@wrapMethod(WeaponRosterGameController)
protected cb func OnUpdate(dT: Float) -> Bool {
  let result: Bool = wrappedMethod(dT);
  this.SetTriggerIndicatorVisibility();
  return result;
}

