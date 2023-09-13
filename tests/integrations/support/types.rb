# frozen_string_literal: true

ParameterType(name:        'path',
              regexp:      %r{/(?:\S+/?)*},
              type:        Pathname,
              transformer: lambda do |str|
                 Pathname.new(str)
              end)

ParameterType(name:        'boolean',
              regexp:      /(enabled|disabled|true|false|on|off|yes|no)/,
              transformer: lambda do |str|
                 %w[enabled true on yes].include? str.downcase
              end)

ParameterType(name:        'html element',
              regexp:      /<(\S+)>/,
              type:        String,
              transformer: lambda do |str|
                 str
              end)
