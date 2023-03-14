# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  scope :sellered_by, ->(username) { where(user: User.where(username: username)) }
  scope :favorited_by, ->(username) { joins(:favorites).where(favorites: { user: User.where(username: username) }) }

  acts_as_taggable

  validates :title, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :slug, uniqueness: true, exclusion: { in: ['feed'] }

  before_validation do
    self.slug ||= "#{title.to_s.parameterize}-#{rand(36**6).to_s(36)}"
  end


  
  # I know I'm not supposed to share this key but OPENAI_API_KEY variable was giving me errors.
  # The part I'm stuck on is accessing just the url value from the Client hash, when I parse to JSON I just get a string obviously
  # and I cant think of a ruby method to extract just the url for use in the response to my client.

  private

  def set_defaults
    response = OpenAI::Client.new(access_token: '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').images.generate(parameters: { prompt: "#{title.to_s}", size: "256x256" })
    
    # ai_image.pluck(:url) ???
    ai_image = JSON.parse response.body, symbolize_names: true
    puts ai_image
    self.image = ai_image if self.image.blank?
  end
end
