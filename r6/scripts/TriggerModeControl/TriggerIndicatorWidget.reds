module TriggerModeControl.Widget
import TriggerModeControl.*
import TriggerModeControl.Config.*

@if(ModuleExists("LimitedHudCommon"))
import LimitedHudCommon.*
@if(ModuleExists("LimitedHudCommon"))
import LimitedHudConfig.WeaponRosterModuleConfig


@addField(WeaponRosterGameController)
let settingsTMC: ref<TMCSettings>;

@addField(WeaponRosterGameController)
let activeTrigger: ref<inkText>;

@addField(WeaponRosterGameController)
let doubledTrigger: Bool;

@addField(WeaponRosterGameController)
let projE3HUD: Bool;

// create and reparent widget
@wrapMethod(WeaponRosterGameController)
protected cb func OnInitialize() -> Bool {
  this.settingsTMC = TMCSettings.GetSettings();
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
  let parent: ref<inkCompoundWidget> = (this.GetRootCompoundWidget().GetWidget(n"weapon_on_foot/ammo_counter/weapon_wrapper/new_ammo_wrapper/selective_fire") as inkCompoundWidget);        // Project E3 - HUD
  if IsDefined(parent) {
    this.projE3HUD = true;
    parent.RemoveAllChildren();
    this.activeTrigger.BindProperty(n"tintColor", n"MainColors.Red");
    this.activeTrigger.SetMargin(95.0, -10.0, 0.0, 0.0);
    this.activeTrigger.SetFontStyle(n"Bold");
    this.activeTrigger.SetFontSize(41);
  } else {
    this.projE3HUD = false;
    // handle smartlink indicator and shared translation
    let translation: Vector2 = new Vector2(0.0, -14.0);
    this.GetRootCompoundWidget().GetWidget(n"weapon_on_foot/ammo_counter").SetTranslation(translation);
    inkWidgetRef.Reparent(this.m_smartLinkFirmwareOffline, this.GetRootCompoundWidget());
    inkWidgetRef.Reparent(this.m_smartLinkFirmwareOnline, this.GetRootCompoundWidget());
    inkWidgetRef.SetAnchor(this.m_smartLinkFirmwareOffline, inkEAnchor.BottomRight);
    inkWidgetRef.SetAnchor(this.m_smartLinkFirmwareOnline, inkEAnchor.BottomRight);
    inkWidgetRef.SetMargin(this.m_smartLinkFirmwareOffline, 0.0, 0.0, 355.0, 0.0);
    inkWidgetRef.SetMargin(this.m_smartLinkFirmwareOnline, 0.0, 0.0, 340.0, 0.0);
    inkWidgetRef.SetTranslation(this.m_smartLinkFirmwareOffline, translation);
    inkWidgetRef.SetTranslation(this.m_smartLinkFirmwareOnline, translation);
    this.GetRootCompoundWidget().GetWidget(n"smartlink_OFF/fluffOff").BindProperty(n"tintColor", n"MainColors.Red");
    // trigger indicator
    parent = (this.GetRootCompoundWidget().GetWidget(n"weapon_on_foot/ammo_counter/additional_info") as inkCompoundWidget);
    parent.SetChildOrder(inkEChildOrder.Backward);
    this.activeTrigger.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
    this.activeTrigger.SetMargin(10.0, -15.0, 10.0, 0.0);
    this.activeTrigger.SetFontStyle(n"Medium");
    this.activeTrigger.SetFontSize(32);
  };
  this.activeTrigger.Reparent(parent);
  return wrappedMethod();
}

@wrapMethod(WeaponRosterGameController)
protected cb func OnUninitialize() -> Bool {
  this.settingsTMC = null;
  this.activeTrigger = null;
  return wrappedMethod();
}

@wrapMethod(WeaponRosterGameController)
private final func Fold() -> Void {
  wrappedMethod();
  if !this.projE3HUD {
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOffline, false);
    inkWidgetRef.SetVisible(this.m_smartLinkFirmwareOnline, false);
  };
}

// select and apply current label
@addMethod(WeaponRosterGameController)
private final func GetTriggerModeKey(secondaryTrigger: Bool) -> CName {
  let triggerStr: String;
  let triggerType: gamedataTriggerMode;
  if secondaryTrigger {
    triggerType = this.m_weaponRecord.SecondaryTriggerMode().Type();
    triggerStr = "Secondary";
  } else {
    triggerType = this.m_weaponRecord.PrimaryTriggerMode().Type();
    triggerStr = "Primary";
  };
  if this.settingsTMC.overrideAuto || this.m_weaponRecord.TagsContains(n"ForceAuto") || this.m_weaponRecord.TagsContains(StringToName("ForceAuto" + triggerStr)) {
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
  if this.settingsTMC.overrideWidget {
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

