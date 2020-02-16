require 'bundler/setup'

require 'dotenv/load'

require 'roda'

require 'activity_streams'
require 'social_web/boot'

SocialWeb.start!

class SocialWebBot < ::Roda
  use SocialWeb[:routes]

  route do |r|
    r.on 'random' do
      response.headers['content-type'] = 'application/json'
      generate(**r.params).to_json
    end

    r.on 'actor' do
      r.post do
        params = r.params.merge(type: 'Actor')
        new_actor = generate(**params)
        SocialWeb['repositories.objects'].store(new_actor)
        
        response.headers['content-type'] = 'application/json'
        new_actor.to_json
      end
    end
  end

  private

  def generate(params = {})
    id = { id: "http://localhost:9292/objects/#{SecureRandom.hex}" }
    ActivityStreams.generate_random(params.merge(id))
  end
end

run SocialWebBot
