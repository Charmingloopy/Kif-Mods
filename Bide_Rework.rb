#===============================================================================
# User bides its time this round and next round. The round after, deals 2x the
# total direct damage it took while biding to the last battler that damaged it.
# (Bide)
#===============================================================================
    class PokeBattle_Move_0D4 < PokeBattle_FixedDamageMove
        def pbAddTarget(targets,user)
          return if user.effects[PBEffects::Bide]!=1   # Not the attack turn
          idxTarget = user.effects[PBEffects::BideTarget]
          t = (idxTarget>=0) ? @battle.battlers[idxTarget] : nil
          if !user.pbAddTarget(targets,user,t,self,false)
            user.pbAddTargetRandomFoe(targets,user,self,false)
          end
        end
      
        def pbMoveFailed?(user,targets)
          return false if user.effects[PBEffects::Bide]!=1   # Not the attack turn
          if user.pbCanLowerStatStage?(:DEFENSE,user,self)
            user.pbLowerStatStage(:DEFENSE,1,user)
          end
          if user.effects[PBEffects::BideDamage]==0
            @battle.pbDisplay(_INTL("But it failed!"))
            user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
            return true
          end
          if targets.length==0
            @battle.pbDisplay(_INTL("But there was no target..."))
            user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
            return true
          end
          return false
        end
      
        def pbOnStartUse(user,targets)
          @damagingTurn = (user.effects[PBEffects::Bide]==1)   # If attack turn
        end
      
        def pbDisplayUseMessage(user)
          if @damagingTurn   # Attack turn
            @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",user.pbThis))
            if user.pbCanLowerStatStage?(:DEFENSE,user,self)
              user.pbLowerStatStage(:DEFENSE,1,user)
            end
            
          elsif user.effects[PBEffects::Bide]>1   # Charging turns
            @battle.pbDisplayBrief(_INTL("{1} is storing energy!",user.pbThis))
           
          else
            super   # Start using Bide
            
          end
        end
      
        def pbDamagingMove?   # Stops damage being dealt in the charging turns
          return false if !@damagingTurn
          return super
        end
      
        def pbFixedDamage(user,target)


          return user.effects[PBEffects::BideDamage]*2.1
          
        end
      
        def pbEffectGeneral(user)
        
          if user.effects[PBEffects::Bide]==0   # Starting using Bide
            if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
              user.pbRaiseStatStage(:DEFENSE,1,user)
            end
            user.effects[PBEffects::Bide]       = 3
            user.effects[PBEffects::BideDamage] = 0
            user.effects[PBEffects::BideTarget] = -1
            user.currentMove = @id
          end
          user.effects[PBEffects::Bide] -= 1
        end

        def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
          hitNum = 1 if !@damagingTurn   # Charging anim
          super
        end
      end