BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    @battlers = battler
    @battles = battle
    @moves = []
    battlerTypes = battler.pbTypes(true)
    type1 = battlerTypes[0]
    type2 = battlerTypes[1] || type1
    type3 = battlerTypes[2] || type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if type1
          moveType = m.type
          if Settings::MECHANICS_GENERATION >= 6 && m.function == "090"    #Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType,type1,type2,type3)
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) && m.function != "070"   # OHKO
        else
          next if m.function != "070"   # OHKO
        end
        
        @moves.append(m.name)
        
        found = true

     end
    end
    if found
      echoln @moves
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end

  }
)
BattleHandlers::DamageCalcTargetAbility.add(:ANTICIPATION,
proc { |ability,user,target,move,mults,baseDmg,type|
    next if @moves.include?(move.name) == false
    next if !move.damagingMove?
    
    mults[:final_damage_multiplier] /= 1.5
    @battles.pbShowAbilitySplash(@battlers)
    @battles.pbDisplay(_INTL("{1} anticipated the attack reducing the damage they took!",@battlers.pbThis))
    @battles.pbHideAbilitySplash(@battlers)
}
)