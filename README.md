# OrgUpdateMatrix

This gem revceives data from a Capistrano run and updates a specified YAML file in the specified GitHub repository.

Depends on the "octokit" gem [https://github.com/octokit/octokit.rb](https://github.com/octokit/octokit.rb)

## Setup

It is a firm requirement that [gitleaks](https://github.com/zricethezav/gitleaks) is run as a `pre-commit` hook. To install the hook run:

    git config core.hooksPath .githooks

Install `gitleaks` with:

    brew install gitleaks

Or on non-MacOS grab a binary from the releases page here: https://github.com/zricethezav/gitleaks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orgupdatematrix'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orgupdatematrix

## Usage

Add to your Capfile:

`require 'orgupdatematrix'`

Add an `:app_url` variable to each deploy env file such as `deploy/environments/staging.rb`:

```
  set :app_url, 'https://staging.my-application.com'
```

Add the `matrix` role to the servers you want to report from:

```
  server 'staging.my-application.com', user: 'deploy', roles: %w{web matrix}
```

Auth: generate a GitHub [personal access token](https://github.com/settings/tokens) and supply it at deploy time:

```
   GITHUB_API_TOKEN=token-value cap production deploy
```

Add the following task to your Capistrano config eg. `deploy/config.rb`:

```
  desc 'Update Matrix'
  task :update_matrix do
    optional_extras = {
      'my_var1' => 'value1',
      'my_var2' => 'value2'
    }
    on roles(:matrix) do
      within repo_path do
        info 'Updating deploy matrix!'
        commit = capture(:git, 'rev-list', '-n', '1', fetch(:branch)).chomp
        updater = OrgUpdateMatrix::Updater.new('GitHubUser/RepoName', 'file-path.yml', ENV['GITHUB_API_TOKEN'])
        updater.update(fetch(:application), fetch(:stage), fetch(:branch), commit, fetch(:app_url), fetch(:repo_url), fetch(:extra_env))
      end
    end
  end

  after :finished, :update_matrix
```

This will update the remote YAML file to look like this:

```
---
app_name:
  stage_name:
    branch: branch_or_tag_name
    commit: 6209dc2138df2ecb808559d8f1c5bc41bfd17d0d
    updated: 2019-05-09 03:51:50 UTC
    app_url: https://staging.my-application.com
    github_url: https://github.com/MyUser/AppRepo.git
    extras:
      my_var1: value1
      my_var2: value2
```

Only the specified `application` + `stage` section will be updated. The rest of the file's contents will remain unchanged.
