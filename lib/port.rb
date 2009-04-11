require 'rubygems'
require 'gosu'
require 'logger'

$: << File.join(File.dirname(__FILE__))

require 'port/gosu_extras'
require 'port/game'
require 'port/window'
require 'port/sprite'
require 'port/path'
require 'port/vehicle'
require 'port/assets'
Dir.glob(File.join(APP_ROOT, 'lib', 'port', 'vehicles', '*.rb')) do |file|
  require file
end

class Application
  attr_accessor :window

  def self.logger
    self.logger ||= Logger.new(STDOUT)
  end
  
  def initialize
    self.window = Window.new(self)
  end

  def run
    @window.show
  end

end

