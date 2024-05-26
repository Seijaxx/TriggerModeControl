public class ManualTriggerSwap {

  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Disclaimer")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideTech")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideTech_desc")
  let overrideTech : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Disclaimer")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideOthers")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideOthers_desc")
  let overrideOthers : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Disclaimer")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideAuto")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideAuto_desc")
  let overrideAuto : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Disclaimer")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideHoldCharge")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideHoldCharge_desc")
  let overrideHoldCharge : Bool = false;

  public static func Create() -> ref<ManualTriggerSwap> {
    let self: ref<ManualTriggerSwap> = new ManualTriggerSwap();
    return self;
  }

}