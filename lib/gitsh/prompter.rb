# encoding: utf-8

require 'gitsh/colors'

module Gitsh
  class Prompter
    DEFAULT_FORMAT = "%D %c%B%#%w".freeze
    BRANCH_CHAR_LIMIT = 15

    def initialize(options={})
      @env = options.fetch(:env)
      @use_color = options.fetch(:color, true)
      @options = options
    end

    def prompt
      reset_chached_repo_info
      padded_prompt_format.gsub(/%[bBcdDw#]/) do |match|
        case match
        when "%b" then branch_name
        when "%B" then shortened_branch_name
        when "%c" then status_color
        when "%d" then Dir.getwd
        when "%D" then File.basename(Dir.getwd)
        when "%w" then clear_color
        when "%#" then terminator
        end
      end
    end

    private

    attr_reader :env

    def reset_chached_repo_info
      @repo_initialized = nil
      @branch_name = nil
      @repo_status = nil
    end

    def padded_prompt_format
      "#{prompt_format.chomp} "
    end

    def prompt_format
      env.fetch('gitsh.prompt') { DEFAULT_FORMAT }
    end

    def shortened_branch_name
      branch_name[0...BRANCH_CHAR_LIMIT] + ellipsis
    end

    def ellipsis
      if branch_name.length > BRANCH_CHAR_LIMIT
        '…'
      else
        ''
      end
    end

    def branch_name
      @branch_name ||= if repo_initialized?
        env.repo_current_head
      else
        'uninitialized'
      end
    end

    def terminator
      if !repo_initialized?
        '!!'
      elsif repo_status.has_untracked_files?
        '!'
      elsif repo_status.has_modified_files?
        '&'
      else
        '@'
      end
    end

    def status_color
      if use_color?
        if !repo_initialized?
          env.repo_config_color('gitsh.color.uninitialized', 'normal red')
        elsif repo_status.has_untracked_files?
          env.repo_config_color('gitsh.color.untracked', 'red')
        elsif repo_status.has_modified_files?
          env.repo_config_color('gitsh.color.modified', 'yellow')
        else
          env.repo_config_color('gitsh.color.default', 'blue')
        end
      else
        Colors::NONE
      end
    end

    def clear_color
      if use_color?
        Colors::CLEAR
      else
        Colors::NONE
      end
    end

    def use_color?
      @use_color
    end

    def repo_initialized?
      if @repo_initialized.nil?
        @repo_initialized = env.repo_initialized?
      end
      @repo_initialized
    end

    def repo_status
      @repo_status ||= env.repo_status
    end
  end
end
