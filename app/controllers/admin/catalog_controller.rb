# frozen_string_literal: true
class Admin::CatalogController < ApplicationController
  before_action :authenticate_user! rescue nil # если у тебя Devise/др. — привяжи как нужно
  layout false

  def families
    fams = Generation.distinct.order(:family).pluck(:family).compact
    render json: { families: fams }
  end

  def generations
    fam = params[:family].to_s
    gens = Generation.by_family(fam).order(:released_on, :title)
    render json: {
      generations: gens.map { |g|
        {
          id: g.id, title: g.title,
          released_on: g.released_on, discontinued_on: g.discontinued_on
        }
      }
    }
  end

  def options
    gen = Generation.find_by(id: params[:generation_id])
    if gen.nil?
      render json: { storage: [], colors: [], phone_id: nil, model_id: nil } and return
    end
    phone = gen.phone
    model = phone&.models&.find_by(title: gen.title) || phone&.models&.first

    render json: {
      storage: gen.storage_options,
      colors: gen.color_options,
      phone_id: phone&.id,
      model_id: model&.id
    }
  end

  def models
    phone = Phone.find_by(id: params[:phone_id])
    render json: {
      models: (phone ? phone.models.order(:title).pluck(:id, :title).map { |id, t| { id: id, title: t } } : [])
    }
  end
end
