require "orgupdatematrix/version"
require "octokit"
require "octopoller"
require "yaml"
require "base64"

module OrgUpdateMatrix
  class Updater
    def initialize(repo, file_path, auth_token)
      @repo = repo
      @file_path = file_path
      @client = Octokit::Client.new(access_token: auth_token)
    end

    def get_file_contents
      @client.contents(@repo, path: @file_path)
    end

    def log(message, indent = 6)
      puts("#{' ' * indent}#{message}")
    end

    def sort_data(hash)
      hash.sort.to_h.each { |app, stage| hash[app] = stage.sort.to_h }
    end

    def update_yaml(file, app, stage, state)
      data = YAML::load(Base64.decode64(file.content))
      data[app] ||= {}
      data[app][stage] = state
      sort_data(data)
    end

    def update(app, stage, branch, commit, app_url, repo_url, extras = nil)
      app = app.to_s
      stage = stage.to_s
      state = {
        'branch' => branch.to_s,
        'commit' => commit,
        'updated' => Time.now.utc.to_s,
        'app_url' => app_url,
        'github_url' => repo_url.gsub('git@', 'https://').gsub(/(\w):(\w)/, '\1/\2'),
      }
      state['extras'] = extras if extras

      log("app: #{app}", 9)
      log("stage: #{stage}", 9)
      state.each { |key, value| log("#{key}: #{value}", 9) }

      Octopoller.poll(wait: :exponentially, retries: 6) do
        begin
          message = "update deploy matrix: #{app}:#{stage}"
          file = get_file_contents
          data = update_yaml(file, app, stage, state)
          result = @client.update_contents(@repo, @file_path, message, file[:sha], data.to_yaml)
          log('Update complete!') if result[:commit]
        rescue StandardError => e
          log("Error: #{e.message}")
          log('Retrying with latest commit...')
          :re_poll
        end
      end
    end
  end
end
