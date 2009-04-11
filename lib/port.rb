require 'rubygems'
require 'gosu'
require 'logger'

$: << File.join(File.dirname(__FILE__))

require 'port/ext/array'
require 'port/gosu_extras'
require 'port/vector'
require 'port/game'
require 'port/window'
require 'port/sprite'
require 'port/path'
require 'port/vehicle'
require 'port/assets'
require 'port/field'
require 'port/fps_counter'
Dir.glob(File.join(APP_ROOT, 'lib', 'port', 'vehicles', '*.rb')) do |file|
  require file
end

class Application
  attr_accessor :window

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
  
  def initialize
    self.window = Window.new(self)
  end

  def run
    @window.show
  end

end

