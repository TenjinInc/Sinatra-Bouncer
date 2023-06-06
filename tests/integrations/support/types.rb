# frozen_string_literal: true

ParameterType(name:        'path',
              regexp:      %r{/(?:\S+/?)*},
              type:        Pathname,
              transformer: ->(str) { Pathname.new(str) })

ParameterType(name:        'boolean',
              regexp:      /(enabled|disabled|true|false|on|off|yes|no)/,
              transformer: ->(str) { %w[enabled true on yes].include? str.downcase })

ParameterType(name:        'html element',
              regexp:      /<(\S+)>/,
              type:        String,
              transformer: ->(str) { str })
