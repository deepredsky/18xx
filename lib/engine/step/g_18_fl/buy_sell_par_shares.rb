# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G18FL
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return [] unless entity == current_entity
          return ['sell_shares'] if must_sell?(entity)
          return ['choose'] if @parred && !@corporation_size
  
          actions = []
          actions << 'buy_shares' if can_buy_any?(entity)
          actions << 'par' if can_ipo_any?(entity)
          actions << 'buy_company' unless purchasable_companies(entity).empty?
          actions << 'sell_shares' if can_sell_any?(entity)
  
          actions << 'pass' unless actions.empty?
          actions
        end

        def active_entities
          return [@parred.entity] if @parred
          return super
        end

        def choice_name
          'Number of Shares'
        end

        def choices
          @game.phase.corporation_sizes
        end

        def pass!
          return par_corporation if @parred

          super
        end

        def process_par(action)
          super
          @corporation_size = nil
          size_corporation(@game.phase.corporation_sizes.first) if @game.phase.corporation_sizes.one?
          @parred = action
          par_corporation
        end

        def par_corporation
          return unless @corporation_size
          @parred = nil
        end

        def process_choose(action)
          size = action.choice
          entity = action.entity
          raise GameError, 'Corporation size is invalid' unless choices.include?(size)

          size_corporation(size)
        end

        def size_corporation(size)
          @corporation_size = size
          @game.convert(@parred.corporation, funding: false) if @corporation_size == 10
        end

        def choice_available?(entity)
          entity.corporation? && entity == @parred&.corporation
        end
      end
    end
  end
end
