# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    # if user.admin?
    #   can :manage, :all
    # else
    #   can :read, :all
    # end

    # For example, here the user can only update published articles.
    # can :update, Article, :published => true

    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
