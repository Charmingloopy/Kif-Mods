BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[:base_damage_multiplier] *= 1.25
      end
      if user.type1==target.type1 or user.type2==target.type2 or user.type1==target.type2 or user.type2==target.type1
        mults[:base_damage_multiplier] *= 1.15
      end
      else
        mults[:base_damage_multiplier] *= 0.75
    end
  }
)
