#===============================================================================
# Stall Rework
#===============================================================================

BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle,user,baseDmg|
   next -1 if subPri==0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STALL,
  proc { |ability,user,target,move,mults,baseDmg,type|
  mults[:attack_multiplier] *= 1.5
  }
)