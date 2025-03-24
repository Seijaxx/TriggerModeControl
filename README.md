# TriggerModeControl
Framework for Cyberpunk2077, to enable specific weapons to swap firemodes at the press of a keybind while leaving all other weapons unaffected.

All credits to rfuzzo, that showed everyone this could be done by writing the initial version.

To make a weapon change firemode manually, instead of the automatic swap that the base game does when changing aiming state, add the `ManualTriggerSwap` tag to the record of the weapon in question:
```yaml
  tags:
    - !append ManualTriggerSwap
```
To tie the attack type to aiming state, rather than manually selectable trigger mode, add the `AimingBoundAttacks` tag to the record of the weapon in question:
```yaml
  tags:
    - !append ManualTriggerSwap
    - !append AimingBoundAttacks
```
To make your firemode keep firing as long as trigger is held (regardless of it actually being TriggerMode.FullAuto) add the `ForceAutoPrimary` and/or `ForceAutoSecondary` tag to the record of the weapon in question:
tags:
```yaml
  tags:
    - !append ForceAutoPrimary
    - !append ForceAutoSecondary
```

### **All available tags listed in the [Wiki](https://github.com/Seijaxx/TriggerModeControl/wiki) tab**.

Keybind is defined in the xml file for Input Loader, `r6/input/ManualTriggerSwap.xml`

---

To give any weapon any stat, and make it apply only to its secondary firemode (regardless of if it's triggered manually or automatically on aim), use `$base: BaseStats.SecondaryDependantStatModifier` instead of `$type: ConstantStatModifier`

For example:
```yaml
  - $base: BaseStats.IsSecondaryDependantStatModifier
    statType: BaseStats.CycleTimeBonus
    modifierType: Additive
    value: 2.0
```
will result in slower firerate only while using its secondary firemode.

`Prereqs.IsPrimaryTrigger` and `Prereqs.IsSecondaryTrigger` are now also available.

---

**Requirements:**
-  redscript
-  Codeware
-  RED4ext
-  Input Loader
-  AchiveXL
-  TweakXL

Check [Wiki](https://github.com/Seijaxx/TriggerModeControl/wiki) for more details
