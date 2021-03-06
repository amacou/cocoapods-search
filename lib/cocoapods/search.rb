require 'rubygems'

module Cocoapods
  module Search
  class LibraryNotFound    < StandardError; end
  class OldRepositoryError < StandardError; end
  class PodError           < StandardError; end
    autoload :Command,   'cocoapods/search/command'
    autoload :Cli,       'cocoapods/search/cli'
    autoload :Pod,       'cocoapods/search/pod'
    autoload :Rendering, 'cocoapods/search/rendering'
    autoload :VERSION,   'cocoapods/search/version'
  end
end
