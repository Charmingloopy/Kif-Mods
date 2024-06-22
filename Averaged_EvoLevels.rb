@body_data = nil
@head_data = nil
class Pokemon
 def get_head_data
    @species_data.head_pokemon.get_evolutions(true).each do |evo|
         # [new_species, method, parameter, boolean]
         next if evo[3] # Prevolution
         ret = evo
         return ret if ret
         end
    return nil
    end
 def get_body_data
    @species_data.body_pokemon.get_evolutions(true).each do |evo|
         # [new_species, method, parameter, boolean]
         next if evo[3] # Prevolution
         
         ret = evo
         return ret if ret
        
         end
    return nil
    end
 def round_evolevels
    if @body_data == nil then
      @body_data = get_body_data
      end
    if @head_data == nil then
      @head_data = get_head_data
      end
    if @head_data and @body_data then
     if @head_data[2] >= @body_data[2] - 3 and @head_data[2] <= @body_data[2] then
       @head_data[2] += @body_data[2] * 0.3
       @head_data[2] = @head_data[2].round()
       end
  end
end

 def check_evolution_on_level_up
    if @species_data.is_a?(GameData::FusedSpecies)
      body = self.species_data.body_pokemon
      head = self.species_data.head_pokemon
     if @head_data == nil then
        @head_data = get_head_data
        end
     if @body_data == nil then
        @body_data = get_body_data
        end

     body_evolution = check_evolution_internal(@species_data.body_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
     head_evolution = check_evolution_internal(@species_data.head_pokemon) { |pkmn, new_species, method, parameter|
        success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
        next (success) ? new_species : nil
      }
     puts head_evolution.inspect.to_s + " head evo"
     current_body = @species_data.body_pokemon
     current_head = @species_data.head_pokemon
     if @head_data[0] != head_evolution
        @head_data = get_head_data
        end
     if head_evolution == nil then
        head_evolution = @head_data[0]
        puts head_evolution.inspect.to_s + " head evo"
        end
     puts @body_data.inspect
     if @head_data == nil then
        @head_data = get_head_data
        end
     if @body_data == nil then
        @body_data = get_body_data
        end
    
     if @body_data then
      if @body_data[0] != body_evolution then
         @body_data = get_body_data
         end
      end
     round_evolevels
     if @body_data  != nil then
       if @body_data[2] < self.level then
         @body_data = get_body_data
         end
       end
     if @head_data  != nil then
      if @head_data[2] < self.level then
        @head_data = get_head_data
        end
      end
     if @body_data != nil then
       if self.level >= @body_data[2] #EVOLVE BODY
        if body_evolution then
          newspecies = getFusionSpecies(body_evolution, current_head)
          end
        end
       end
     if @head_data != nil then
       if self.level >= @head_data[2] #EVOLVE HEAD
        if head_evolution then
         newspecies = getFusionSpecies(current_body, head_evolution)
         end
        end
       end

     puts @head_data.inspect.to_s + " head data"
     puts @body_data.inspect.to_s + " body data"
     if newspecies then
       return newspecies
      end
     @body_data = nil
     @head_data = nil
     return nil
     end
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_level_up(pkmn, parameter)
      next (success) ? new_species : nil
      }
    end
 end