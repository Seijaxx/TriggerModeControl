module TriggerModeControl.Config

@if(ModuleExists("ModSettingsModule"))
import ModSettingsModule.*


public class TMCSettings extends ScriptableSystem {

  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideTech")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideTech_desc")
  let overrideTech : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideOthers")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideOthers_desc")
  let overrideOthers : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideAuto")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideAuto_desc")
  let overrideAuto : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideHoldCharge")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideHoldCharge_desc")
  let overrideHoldCharge : Bool = false;
  
  
  
  public static func GetSettings() -> ref<TMCSettings> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"TriggerModeControl.Config.TMCSettings") as TMCSettings;
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }
  
}
