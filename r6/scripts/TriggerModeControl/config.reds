public class ManualTriggerSwap {

  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Disclaimer")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-AffectAll")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-AffectAll_desc")
  let affectAll : Bool = false;

  public static func Create() -> ref<ManualTriggerSwap> {
    let self: ref<ManualTriggerSwap> = new ManualTriggerSwap();
    return self;
  }

}